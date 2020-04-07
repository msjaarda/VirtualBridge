% Plot AGB Results

% Initial Commands
clear, clc, close all
% Load AGB Results
load('AGBResults.mat') % AGB.(Section).(Config).(Dist).(AE)

PlotMAT = true;

Folder_Name = 'AGB2002x';

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
    
    if ~iscell(OInfo(i).BaseData.TransILx)
        Sectionx = 'Box';
    elseif strcmp(OInfo(i).BaseData.TransILx{:},'1.5,5.5')
        Sectionx = 'TwinRed';
    elseif strcmp(OInfo(i).BaseData.TransILx{:},'2.5,8.5')
        Sectionx = 'TwinExp';
    elseif strcmp(OInfo(i).BaseData.TransILy{:},'0.9,0.1')
        Sectionx = 'Twin';
    else
        Sectionx = 'TwinConc';
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
            end
        catch
            MAT.(Sectionx).(Configx).(Distx).(AEx) = XT;
            MAT.(Sectionx).(Configx).(Distx).(AEx).(Locx)(Span/10) = OInfo(i).ESIM(k);
        end
        %AExL = AEx;
    end

end


%Fig = 4.2; %4.2 to 4.6 or 'Custom' and fill out the below
Fig = 4.2:0.1:4.6;

% Custom Input

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
Loc{1} = 'GD'; Loc{2} = 'MD'; Loc{3} = 'DD'; Loc{4} = 'DetD';
% Set Colors
Col{1} = [0.9100 0.4100 0.1700]; Col{2} = [0.2745 0.6863 0.8902];
Col{3} = [0.2745 0.8314 0.1922]; Col{4} = [0.6 0.6 0.6];

% Set Plot Size Parameters
MSize = 5; LWid = 1; Xmin = 10;

% Initialize Figure
figure('Name',FName,'NumberTitle','off')

for i = 1:3 % for each subplot
    % Open subplot
    subplot(1,3,i)
    % Get X/Y data
    X = 10:10:80; X = X';
    Y = AGB.(Section{i}).(Config).(Dist{i}).(AE{i});

    if PlotMAT
        Yx = MAT.(Section{i}).(Config).(Dist{i}).(AE{i});
    end
    for j = 3 % for each traffic case
        if j == 4
            scale = 1;
        else
            scale = 1.1;
        end
        hold on
        % Get only indices that have results
        Inds = ~isnan(Y.(Loc{j})) & X >= Xmin;
        plot(X(Inds),Y.(Loc{j})(Inds)*scale./Y.E(Inds),'-s','Color',Col{j},'MarkerEdgeColor','none','MarkerFaceColor',Col{j},'MarkerSize',MSize)   
        if PlotMAT
            Indsx = ~isnan(Y.(Loc{j})) & X >= Xmin;
            hold on
            plot(X(Indsx),Yx.(Loc{j})(Indsx)./Y.E(Indsx),'-s','Color','k','MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',MSize)
        end
    end
    
    % Set tick details
    ytickformat('%.2f'); xticks(Xmin:10:80); set(gca,'TickDir','out'); set(gca,'YGrid','on')
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
    
end

% Set figure position
set(gcf,'Position',[50+175*(k-1) 0+50*(k-1) 900 500])

end