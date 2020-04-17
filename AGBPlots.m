% Plot AGB Results

% Initial Commands
clear, clc, close all
% Load AGB Results
load('AGBResults.mat') % AGB.(Section).(Config).(Dist).(AE)

PlotMAT = true;
PlotMargins = true;
AlwaysTME = true;
% Plot toggles (1 through 5 are Got, Mat, Den, Det, Cen2018)
% Cen2018 needs updating
MATPlots = [1 2 3 4];
Acc = [];

%Fig = 4.3; %4.2 to 4.6 or 'Custom' and fill out the below
Fig = 4.2:0.1:4.6;

Folder_Name = 'AGB2002A15';

% Ensure file list is succinct
File_List = dir(['Output/' Folder_Name]); File_List(1:2) = []; i = 1;
% Take only .mat files (no excel files)
while i <= length(File_List)
    if File_List(i).name(end-4:end) == '.xlsx'
        File_List(i) = [];
    else
        i = i + 1;
    end
end
% Read in .mat results variables
for i = 1:length(File_List)
    load(['Output/' Folder_Name '/' File_List(i).name])
    OInfo(i) = OutInfo;
end

clear OutInfo

% Initialize
% Initialize 8x12 table with nans
X = NaN(8,12);
XT = array2table(X,'VariableNames',{'EQ1','EQ2','Eq','GS','GD','MS','MD','DS','DD','DetS','DetD','E'});
% MAT.(Sectionx).(Configx).(Distx).V = XT;
% MAT.(Sectionx).(Configx).(Distx).Mp = XT;
% MAT.(Sectionx).(Configx).(Distx).Mn = XT;
        
for i = 1:length(OInfo)
    
    if iscell(OInfo(i).BaseData.TransILx)
        if OInfo(i).BaseData.TransILx{:} == '0'
            Sectionx = 'Box';
        elseif strcmp(OInfo(i).BaseData.TransILx{:},'1.5,5.5')
            Sectionx = 'TwinRed';
        elseif strcmp(OInfo(i).BaseData.TransILx{:},'2.5,8.5')
            Sectionx = 'TwinExp';
        elseif strcmp(OInfo(i).BaseData.TransILy{:},'0.9,0.1')
            Sectionx = 'Twin';
        else% strcmp(OInfo(i).BaseData.TransILy{:},'0.7,0.3')
            Sectionx = 'TwinConc';
        end
    else
        Sectionx = 'Box';
    end
    
    if OInfo(i).BaseData.NumVeh == 1000000
        Configx = 'Bi';
    else
        Configx = 'Mo';
    end
    
    if strcmp(OInfo(i).BaseData.LaneTrDistr{:},'50,50')
        Distx = 'Split';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'96,4')
        Distx = 'Stand';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'85,15')
        Distx = 'ExFast';
    else
        Distx = 'ExSlow';
    end
    
    if OInfo(i).BaseData.TrRate == 0.29
        Locx = 'GD';
    elseif OInfo(i).BaseData.TrRate == 0.14
        Locx = 'MD';
    elseif OInfo(i).BaseData.TrRate == 0.07
        Locx = 'DD';
    elseif OInfo(i).BaseData.TrRate == 0.12 % use DetS for Ceneri
        Locx = 'DetS';
    else
        Locx = 'DetD';
    end
    
    % Let's not worry about ESIA for now... just get SimResults ESIM
    %MAT.(Sectionx).(Configx).(Distx).(AEx).(Locx)
    % We need to get  Loc{1} = 'GD'; Loc{2} = 'MD'; Loc{3} = 'DD'; Loc{4} = 'DetD';
    

    %MAT.(Sectionx).(Configx).(Distx).(AEx) = XT;
    %AExL = 0;
    for k = 1:length(OInfo(i).ESIM)
        if strcmp(Sectionx,'Box')
            Temp = OInfo(i).InfNames{k};
        else % Had to add because there are 2 influence lines for each Twin ESIM
            Temp = OInfo(i).InfNames{2*k};
        end
        Span = str2num(Temp(end-1:end));
        AEx = Temp(1:end-2);
%         if ~isequal(AEx,AExL)
%             if ~istable(MAT.(Sectionx).(Configx).(Distx).(AEx))
%                 MAT.(Sectionx).(Configx).(Distx).(AEx) = XT;
%             end
%         end
        try
            if istable(MAT.(Sectionx).(Configx).(Distx).(AEx))
                MAT.(Sectionx).(Configx).(Distx).(AEx).(Locx)(Span/10) = OInfo(i).ESIM(k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).([Locx(1:end-1) 'S'])(Span/10) = OInfo(i).ESIMS(k);
                % Only if it has it
                if ~isempty(OInfo(i).ESIA)
                    
                    MAT.(Sectionx).(Configx).(Distx).(AEx).E(Span/10) = OInfo(i).ESIA.Total(k);
                    MAT.(Sectionx).(Configx).(Distx).(AEx).Eq(Span/10) = OInfo(i).ESIA.Eq(k);
                    MAT.(Sectionx).(Configx).(Distx).(AEx).EQ1(Span/10) = OInfo(i).ESIA.EQ(1,k);
                    MAT.(Sectionx).(Configx).(Distx).(AEx).EQ2(Span/10) = OInfo(i).ESIA.EQ(2,k);
                end
            end
        catch
            MAT.(Sectionx).(Configx).(Distx).(AEx) = XT;
            MAT.(Sectionx).(Configx).(Distx).(AEx).(Locx)(Span/10) = OInfo(i).ESIM(k);
            MAT.(Sectionx).(Configx).(Distx).(AEx).([Locx(1:end-1) 'S'])(Span/10) = OInfo(i).ESIMS(k);
            % Only if it has it
            if ~isempty(OInfo(i).ESIA)
                
                MAT.(Sectionx).(Configx).(Distx).(AEx).E(Span/10) = OInfo(i).ESIA.Total(k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).Eq(Span/10) = OInfo(i).ESIA.Eq(k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).EQ1(Span/10) = OInfo(i).ESIA.EQ(1,k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).EQ2(Span/10) = OInfo(i).ESIA.EQ(2,k);
            end
        end
        %AExL = AEx;
    end

end



% Custom Input

% Assign Figure Name
FName = 'Figure 4.2 Box Girder, Bidirectional';

% Set Plot Parameters
Section = 'Box'; % Box, Twin, TwinRed, TwinExp, TwinConc
Config = 'Bi';   % Bi, Mo
%Dist = 'Split'; % Split, Stand, ExFast, ExSlow

% Set Action Effects
AE{1} = 'Mn'; AE{2} = 'Mp'; AE{3} = 'V';
% Set Titles
Title{1} = 'M-'; Title{2} = 'M+'; Title{3} = 'V';

for k = 1:length(Fig)

if Fig(k) == 4.2
    
    % Assign Figure Name
    FName = 'Figure 4.2 Box Girder, Bidirectional';
    
    % Set Plot Parameters
    Section = 'Box'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Bi';   % Bi, Mo
    Dist = 'Split'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE{1} = 'Mn'; AE{2} = 'Mp'; AE{3} = 'V';
    % Set Titles
    Title{1} = 'M-'; Title{2} = 'M+'; Title{3} = 'V';
    
elseif Fig(k) == 4.3
    
    % Assign Figure Name
    FName = 'Figure 4.3 Box Girder, Motorway';
    
    % Set Plot Parameters
    Section = 'Box'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Mo';   % Bi, Mo
    Dist{1} = 'ExFast';  Dist{2} = 'Stand'; Dist{3} = 'ExSlow'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE{1} = 'Mp'; AE{2} = 'Mp'; AE{3} = 'Mp';
    % Set Titles
    Title{1} = 'M+ 85%-15%'; Title{2} = 'M+ 96%-4%'; Title{3} = 'M+ 100%-0%';
    
elseif Fig(k) == 4.4
    
    % Assign Figure Name
    FName = 'Figure 4.4 Twin Girder, Bidirectional';
    
    % Set Plot Parameters
    Section = 'Twin'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Bi';   % Bi, Mo
    Dist = 'Split'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE{1} = 'Mn'; AE{2} = 'Mp'; AE{3} = 'V';
    % Set Titles
    Title{1} = 'M-'; Title{2} = 'M+'; Title{3} = 'V';
    
elseif Fig(k) == 4.5
    
    % Assign Figure Name
    FName = 'Figure 4.5 Twin Girder, Bidirectional';
    
    % Set Plot Parameters
    Section{1} = 'TwinRed'; Section{2} = 'TwinExp'; Section{3} = 'TwinConc'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Bi';   % Bi, Mo
    Dist = 'Split'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE = 'Mp';
    % Set Titles
    Title{1} = 'M+ Reduced'; Title{2} = 'M+ Expanded'; Title{3} = 'M+ Concrete';
    
elseif Fig(k) == 4.6
    
    % Assign Figure Name
    FName = 'Figure 4.6 Twin Girder, Motorway';
    
    % Set Plot Parameters
    Section = 'Twin'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Mo';   % Bi, Mo
    Dist{1} = 'ExFast';  Dist{2} = 'Stand'; Dist{3} = 'ExSlow'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE = 'Mp';
    % Set Titles
    Title{1} = 'M+ 85%-15%'; Title{2} = 'M+ 96%-4%'; Title{3} = 'M+ 100%-0%';
    
end

% Convert to cellular if necessary
if ~iscell(Section)
    temp = Section; clear Section
    [Section{1:3}] = deal(temp);
end
if ~iscell(AE)
    temp = AE; clear AE
    [AE{1:3}] = deal(temp);
end
if ~iscell(Dist)
    temp = Dist; clear Dist
    [Dist{1:3}] = deal(temp);
end

% Set Locations
Loc{1} = 'GD'; Loc{2} = 'MD'; Loc{3} = 'DD'; Loc{4} = 'DetD'; Loc{5} = 'DetS';
% Set Colors
Col{1} = [0.9100 0.4100 0.1700]; Col{2} = [0.2745 0.6863 0.8902];
Col{3} = [0.2745 0.8314 0.1922]; Col{4} = [0.6 0.6 0.6];

% Set Plot Size Parameters
MSize = 5; LWid = 1; Xmin = 20;

% Initialize Figure
figure('Name',FName,'NumberTitle','off')

for i = 1:3 % for each subplot
    % Open subplot (change 2 back to 1 for original)
    if PlotMargins
        subplot(2,3,i)
    else
        subplot(1,3,i)
    end
    % Get X/Y data
    X = 10:10:80; X = X';
    Y = AGB.(Section{i}).(Config).(Dist{i}).(AE{i});

    if PlotMAT
        Yx = MAT.(Section{i}).(Config).(Dist{i}).(AE{i});
    end
    for j = MATPlots % for each traffic case
        if j == 4
            % Scale is a scaling factor to account for gamma model
            scale = 1;
        else
            scale = 1.1;
        end
        hold on
        % Get only indices that have results
        if j < 5
            Inds = ~isnan(Y.(Loc{j})) & X >= Xmin;
            plot(X(Inds),Y.(Loc{j})(Inds)*scale./Y.E(Inds),'-s','Color',Col{j},'MarkerEdgeColor','none','MarkerFaceColor',Col{j},'MarkerSize',MSize)
        end

        if PlotMAT
            if j == 5
                Inds = ~isnan(Yx.(Loc{j})) & X >= Xmin;
            end
            hold on
            if AlwaysTME
                plot(X(Inds),Yx.(Loc{j})(Inds)./Y.E(Inds),'-s','Color','k','MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',MSize)
            else
                plot(X(Inds),Yx.(Loc{j})(Inds)./Yx.E(Inds),'-s','Color','k','MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',MSize)
            end
            bp = zeros(1,size(X,1));
            bp(Inds') = [Y.(Loc{j})(Inds)*scale]./[Yx.(Loc{j})(Inds)];
            % Acc is accuracy of MATSim compared to TM
            Acc = [Acc; bp];
        end
    end
    % Track which of the traffic cases was the highest, for use in
    % Margin Plot
    if strcmp(Section{i},'Box')
        alphasq = 0.5;
    else
        alphasq = 0.4;
    end
    Esimmax = max([Y.GD'; Y.MD'; Y.DD'; Y.DetD']);
    Eupdated = 1.5/1.1*(0.7*Y.EQ1 + 0.5*Y.EQ2 + alphasq*Y.Eq);
    % Optional below: Yx or Y
    if AlwaysTME
        Eupdatedx = 1.5*(0.7*Y.EQ1 + 0.5*Y.EQ2 + alphasq*Y.Eq);
    else
        Eupdatedx = 1.5*(0.7*Yx.EQ1 + 0.5*Yx.EQ2 + alphasq*Yx.Eq);
    end
    M = Eupdated./Esimmax'-1;
    if PlotMAT
        Esimmaxx = max([Yx.GD'; Yx.MD'; Yx.DD'; Yx.DetD']);
        Mx = Eupdatedx./Esimmaxx'-1;
    end
    
    % Set tick details
    ytickformat('%.2f'); yticks(0:0.1:1); xticks(Xmin:10:80); set(gca,'TickDir','out'); set(gca,'YGrid','on')
    % Set title
    title(Title{i})

    % get handle of current, set box property to off and remove background color
    a = gca; set(a,'box','off','color','none');
    % create new, empty axes with box but without ticks
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active, and link axes in case of zooming
    axes(a); linkaxes([a b]);    
    
    % Set axis limits
    ylim([0 1]); xlim([Xmin 80])
    
    if PlotMargins
    
        subplot(2,3,i+3)
        fill([0 0 30 50 80 80 0],[0 0.2 0.2 0.1 0.1 0 0],[0.8 0.8 0.8],'EdgeColor','none','LineWidth',1.5);
        hold on
        Inds = M > 0;
        plot(X(Inds),M(Inds),'-s','Color','r','MarkerEdgeColor','none','MarkerFaceColor','r','MarkerSize',MSize)
        % Set tick details
        ytickformat('%.2f'); xticks(Xmin:10:80); set(gca,'TickDir','out'); set(gca,'YGrid','on')
        % get handle of current, set box property to off and remove background color
        a = gca; set(a,'box','off','color','none');
        % create new, empty axes with box but without ticks
        b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[]);
        % set original axes as active, and link axes in case of zooming
        axes(a); linkaxes([a b]);
        
        % Set axis limits
        ylim([0 0.5]); xlim([Xmin 80])
        xlabel('-2\pi < x < 2\pi') 
        ylabel('Sine and Cosine Values') 
        title([Title{i} ' Margin'])
        
               
        if PlotMAT
            hold on
            plot(X(Inds),Mx(Inds),'-s','Color','k','MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',MSize) 
        end
    
    end
    
end

% Set figure position
if PlotMargins
    set(gcf,'Position',[50+175*(k-1) -100+50*(k-1) 700 700])
else
    set(gcf,'Position',[50+175*(k-1) 0+50*(k-1) 900 500])
end

end