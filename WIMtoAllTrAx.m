function [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,SpaceSaver)
% WIMTOALLTRAX

% This function could use a lot of work
%   - Organization
%   - Runtime optimization
%   - Smart detection of decimal seconds

% We have to treat the lanes together this is the only way to preserve the 
% interaction between lanes (otherwise one lane will grow or shrink too much,
% and vehicles that are actually beside each other won't appear to be so.)

% Head describes the vehicle number... including light vehicles. It resets
% to zero randomly, so it is difficult to know actually how many vehicles
% pass by in the year.

EnhancedWIM = ismember('HH', PDCx.Properties.VariableNames);
VWIM = ismember('AllAxSpCu', PDCx.Properties.VariableNames);

% Clean up WIM data (if enhanced WIM file)
if EnhancedWIM
    % First fix PDCx.Head
    % Find indices where it resets to zero
    Q = [0; diff(PDCx.Head)];
    Q(Q < 0) = PDCx.Head(Q < 0);
    PDCx.Head = cumsum(Q);
    TR = height(PDCx)/PDCx.Head(end);
    
    % Fix decimal seconds
    PDCx.HH = str2double(PDCx.HH)/100;
    
    % Changes variables names to be lane specific
    PDCx.Properties.VariableNames{'HEADx'} = 'LnHead';
    PDCx.Properties.VariableNames{'GAP'} = 'LnGap';
    
    PDCx = sortrows(PDCx,{'JJJJMMTT','HHMMSS','HH'});
elseif ~VWIM
    PDCx = sortrows(PDCx,{'JJJJMMTT','HHMMSS'});
end

% For some reason additing sortrows changes the result!
% 0428 at 201136 is when we have 4 vehicles close

Lanes = unique(PDCx.FS);

% We notice that two vehicles can arrive at the same time in the same lane... SO 
% we can try a crude method of simply assigning vehicles that arrive at the same 
% second as others and early and late decimal value (0.15, and 0.85 for example).
if ~EnhancedWIM
    % Must be a lane-specific procedure
    for i = 1:length(Lanes)
        
        % Find indeces of the lane we are working in
        LaneInds = PDCx.FS == Lanes(i);
        DC = rand(height(PDCx(LaneInds,1)),1);
        
        % Find all locations where truck i and i - 1 arrived at the same time
        AA = [1; diff(PDCx.HHMMSS(LaneInds))];
        
        % Replace with early and late decimal values
        DC(find(AA == 0)-1) = 0.15;
        DC(AA == 0) = 0.85;
        
        PDCx.HH(LaneInds) = DC; 
    end
end

% Repeat even if vehicles are in different lanes (WIM station logged one
% before the other for a reason... although they could have the same time

% We don't need this stuff if we have VWIM

if VWIM
    PDCx.CumDist = PDCx.AllAxSpCu;
    
    % Could add space-saver like properties here... can't use Dist
%     if SpaceSaver > 0
%         PDCx.Dist(PDCx.Dist > SpaceSaver) = SpaceSaver;
%     end
    
else
    
    PDCx.TStamp = 60*60*24*(PDCx.Daycount-1) + 60*60*floor(PDCx.HHMMSS/10000) + 60*floor(rem(PDCx.HHMMSS,10000)/100) + rem(PDCx.HHMMSS,100) + PDCx.HH;
    PDCx.DeltaT = [0; diff(PDCx.TStamp)];
    PDCx.Dist = PDCx.DeltaT.*((PDCx.SPEED/100)*0.2777777777778); PDCx.Dist(1) = 1;
    
    % We can do spacesaver here since we treat all at the same time...
    if SpaceSaver > 0
        PDCx.Dist(PDCx.Dist > SpaceSaver) = SpaceSaver;
    end
    
    % Cummulative distance in axle stream
    PDCx.CumDist = cumsum(PDCx.Dist);
    
end

PDCx.LnTrSpacing = zeros(height(PDCx),1);
PDCx.LnTrBtw = zeros(height(PDCx),1);

for i = 1:length(Lanes)
    % Find indices of the lane we are working in
    LaneInds = PDCx.FS == Lanes(i);
    
    % Find all locations where truck i and i - 1 arrived at the same time
    AA = [0; diff(PDCx.CumDist(LaneInds))];
    
    PDCx.LnTrSpacing(LaneInds) = AA;
    PDCx.LnTrBtw(LaneInds) = AA - PDCx.LENTH(circshift(find(LaneInds == 1),1))/100;
    
end

% Create wheelbase and axle load vectors
if VWIM
    WBL = PDCx{:,34:40}/100;
    AX = PDCx{:,24:31}/102;
else
    WBL = PDCx{:,24:30}/100;
    AX = PDCx{:,14:21}/102;
end


WBL = cumsum(WBL,2);
WB = [PDCx.CumDist PDCx.CumDist+WBL];

% Must eliminate useless WB values
WB(AX == 0) = 0;
T = ones(size(AX)).*(AX > 0);
TrNum = 1:size(WB,1); TrNum = TrNum';
Q = repmat(TrNum,1,size(T,2));
TrNum = Q.*T;

LaneNum = PDCx.FS;
Q = repmat(LaneNum,1,size(T,2));
LaneNum = Q.*T;

x = WB'; WBv = x(:);
x = AX'; AXv = x(:);
x = TrNum'; TrNum = x(:);
x = LaneNum'; LaneNum = x(:);

% v stands for vector (not matrix)
WBv = WBv(WBv > 0);
AXv = AXv(AXv > 0);
TrNum = TrNum(TrNum > 0);
LaneNum = LaneNum(LaneNum > 0);

%AllLaneLineUp = [AllAxSpCu(1) AllAxLoads(2) AllVehNum(3) AllLaneNum(4)...
TrLineUp = [WBv AXv TrNum LaneNum];

% Round to 1
TrLineUp(:,1) = round(TrLineUp(:,1));

% % Make a separate axle stream vector for each lane, and last one for all
AllTrAx = zeros(max(TrLineUp(:,1)),length(Lanes)+1);

for i = 1:length(Lanes)
    A = accumarray(TrLineUp(TrLineUp(:,4)==Lanes(i),1),TrLineUp(TrLineUp(:,4)==Lanes(i),2));
    AllTrAx(1:length(A(1:1:end)),i) = A(1:1:end); 
end

AllTrAx(:,end) = sum(AllTrAx(:,1:end-1),2);

% If we want to output exact axle locations
TrLineUp(:,1) = WBv;



% % % % Take HHMMSS and convert to time
% % % dys = PDCx.Daycount-1; hrs = floor(PDCx.HHMMSS/10000); mns = floor(rem(PDCx.HHMMSS,10000)/100);
% % % 
% % % 
% % % if EnhancedWIM
% % %     PDCx.HHMMSS = PDCx.HHMMSS + str2double(PDCx.HH)/100;
% % %     scs = rem(PDCx.HHMMSS,100);
% % % else
% % %     scs = rem(PDCx.HHMMSS,100);% + rand(length(dys),1);
% % % end


% % % % Add time together
% % % Time = 60*60*24*dys + 60*60*hrs + 60*mns + scs;

% We notice is that three vehicles never arrive at the same second... SO 
% we can try a crude method of simply assigning vehicles that
% arrive at the same second as others and early and late mil (0.15, and
% 0.85 for example).

% If we have decimal second data, it is already added

% % % % Nowe we split into a lane-specific procedure
% % % for i = 1:length(Lanes)
% % %     % Find indeces of the lane we are working in
% % %     LaneInds = PDC.FS == Lanes(i);
% % %     
% % %     % Find all locations where truck i and i - 1 arrived at the same time
% % %     % Note that with decimal second data, this will never happen
% % %     AA = [1; diff(PDC.HHMMSS(LaneInds))];
% % %     
% % %     scsS{i}(find(AA == 0)-1) = scs(find(AA == 0)-1) + 0.15;
% % %     scsS{i}(find(AA == 0)) = scs(find(AA == 0)) + 0.85;
% % %     
% % % end


% dtime = zeros(length(time),1);
% speed = zeros(length(time),1);

% for i = 1:length(Lanes)
%     dtime(PDC.FS == Lanes(i)) = [0; diff(time(PDC.FS == Lanes(i)))];
%     PDC.dtime(PDC.FS == Lanes(i)) = dtime(PDC.FS == Lanes(i));
%     speed(PDC.FS == Lanes(i)) = (mean([PDC.SPEED(PDC.FS == Lanes(i)) circshift(PDC.SPEED(PDC.FS == Lanes(i)),1)],2)/100)*0.2777777777778;
%     PDC.Dist(PDC.FS == Lanes(i)) = dtime(PDC.FS == Lanes(i)).*speed(PDC.FS == Lanes(i));
%     PDC.DistBw(PDC.FS == Lanes(i)) = PDC.Dist(PDC.FS == Lanes(i))-circshift(PDC.LENTH(PDC.FS == Lanes(i)),1)/100;
%     % Problem is... PDC.Dist is now lane specific. Spacesaver won't work
% end

%         histogram(PDC.SPEED/100,'Normalization','pdf','BinWidth',1,'EdgeColor','r','FaceColor',[0.4 0.4 0.4],'FaceAlpha',1)
%
%         title([SName ' ' num2str(Year) ' Speed'])
%         xlabel('Speed (kph)')
%         xlim([0 120])
%         ylabel('PDF')
%         set(gca,'ytick',[])
%         set(gca,'yticklabel',[])


% figure(2)
% histogram(PDCx.LnTrBtw(PDCx.FS == 4),'Normalization','pdf','BinWidth',1,'EdgeColor','r','FaceColor',[0.4 0.4 0.4],'FaceAlpha',1)
% 
% %title([SName ' ' num2str(Year) ' Time of Day'])
% xlabel('Time (hrs)')
% %xlim([0 100])
% ylabel('PDF')
% set(gca,'ytick',[])
% set(gca,'yticklabel',[])

% Now turn it into a AllTrAx!

% Find a way to convert time to distance?




% Put summa this garbage into other functions


% Decide what to do with these guys...
%         PDCx.Dist(PDCx.Dist < 0) = 52.22222222;
%         PDCx.Dist(PDCx.Dist > 10000) = 52.22222222;

%X = PDCx.Dist(PDCx.Dist > 0 & PDCx.Dist < 6000);
%X = PDCx.Dist;

% Right now we use PDCx.LENTH, not WBLen + TrFront + TrEnd
%PDCx.WBLen = sum(PDCx{:,24:32},2);

%figure(2)
%         count = count + 1;
%         subplot(length(Stations),length(Lanes),count)
%         histogram(X,'Normalization','pdf','BinWidth',5,'EdgeColor','r','FaceColor',[0.4 0.4 0.4],'FaceAlpha',1)
%
%         title([num2str(Station) ' ' num2str(Lanes(j))])
%         xlabel('Distance (m)')
%         xlim([0 200])
%         ylabel('PDF')
%         set(gca,'ytick',[])
%         set(gca,'yticklabel',[])

%dtime(dtime <= 0) = NaN;

%         figure(3)
%         histogram(speed,'Normalization','pdf','BinWidth',0.25,'EdgeColor','r','FaceColor',[0.4 0.4 0.4],'FaceAlpha',1)
%
%         title([SName ' ' num2str(Year) ' '])
%         xlabel('Distance (m)')
%         xlim([18 28])
%         ylabel('PDF')
%         set(gca,'ytick',[])
%         set(gca,'yticklabel',[])



%WBv = round(WBv);

% accumarray
% Things to return (if made into a function)


% Might be able to get rid of this loop... build like ALlLaneLineUp
% with the 4 (or 3 if we don't do AllVehNum) columns, and then
% separate at the end!

%end

%sgtitle([SName ' ' num2str(Year) ' Distance Between Trucks ']);
% fprintf('\n\n');





