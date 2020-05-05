% Plot AGB Results

% Initial Commands
clear, clc, close all

% INPUT ---------------

% Plot Toggles
PlotOriginal = true;
PlotMargins = true;
PlotMAT1 = true;
PlotMAT2 = false;
PlotCeneriM = true;
% Plot Series Toggles (1 through 5 are Got 03, Mat 03, Den 03, Det, Cen 18)
Plots = [1 2 3 4 5 6];
% Use TM's E (slightly different than MATSim E)
AlwaysTME = false;
% Saving
SaveFig = false;
SaveFolder = 'AGBPlots';
SaveSuffix = '';

% Legend labels (Original)
J{1} = 'Got 03'; J{2} = 'Mat 03'; J{3} = 'Den 03'; J{4} = 'Det 23/CG';
% Optional extra Legend labels
J{5} = 'MSim'; J{6} = 'Cen 18'; %J{7} = 'Cen 18 10x Traf';

% Initialize vector for calculating accuracy
Acc = [];

%Fig = 4.2; %or 'Custom' and fill out lower down details
Fig = 4.2%:0.1:4.6;

% INPUT OVER ----------

% Set Colors
Col{1} = [0.91 0.41 0.17]; Col{2} = [0.27 0.69 0.89];
Col{3} = [0.27 0.83 0.19]; Col{4} = 0.6*ones(1,3);

% Set Plot Size Parameters
MSize = 5; LWid = 1; Xmin = 20;

% Load AGB Results
load('AGBResults.mat') % AGB.(Section).(Config).(Dist).(AE)
GammaS = 1.1;
% Load AGBMAT2 Results
load('AGBMATResultsf50k.mat') % AGBMAT.(Section).(Config).(Dist).(AE)
MAT2 = MAT;
% Load AGBMAT1 Results
load('AGBMATResults.mat') % AGBMAT.(Section).(Config).(Dist).(AE)

% X Data (Y gives in each loop)
X = 10:10:80; X = X';

% CUSTOM INPUT ----------

% Assign Figure Name
FName = 'Figure 4.2 Box Girder, Bidirectional';

% Set Plot Parameters
% Set Section
Section{1} = 'Box';
% Box, Twin, TwinRed, TwinExp, TwinConc
% Set Configuration
Config{1} = 'Bi';  
% Bi, Mo
% Set Distribution
Dist{1} = 'Split'; % Split, Stand, ExFast, ExSlow
% Set Action Effects
AE{1} = 'Mn'; AE{2} = 'Mp'; AE{3} = 'V';
% Set Titles
Title{1} = 'M-'; Title{2} = 'M+'; Title{3} = 'V';
% Set Locations
Loc{1} = 'GD'; Loc{2} = 'MD'; Loc{3} = 'DD'; Loc{4} = 'DetD';
Loc{5} = 'CD'; Loc{6} = 'xTCD';

% CUSTOM INPUT OVER ----------





% For each figure
for k = 1:length(Fig)

% Get Figure Details if input isn't custom
if Fig(k) == 4.2 || Fig(k) == 4.3 || Fig(k) == 4.4 || Fig(k) == 4.5 || Fig(k) == 4.6 
    [FName,Section,Config,Dist,AE,Title] = AGBFigDets(Fig(k));
end

% Initialize Figure
figure('Name',FName,'NumberTitle','off')

% For each subplot
for i = 1:3
    % Subdivide acccording to whether we are also plotting Margins
    if PlotMargins
        subplot(2,3,i)
    else
        subplot(1,3,i)
    end
    
    % Get Y data
    if PlotOriginal
        Y = AGB.(Section{i}).(Config).(Dist{i}).(AE{i});
    end
    if PlotMAT1
        Y1 = MAT.(Section{i}).(Config).(Dist{i}).(AE{i});
    end
    if PlotMAT2
        Y2= MAT2.(Section{i}).(Config).(Dist{i}).(AE{i});
    end
    
    % For each traffic case
    for j = Plots
        
        hold on
        
        % Plot AGB Originals (from TM's work)
        if PlotOriginal
            if j < 5 % There are no original AGB Results for j > 5
                % Get only indices that have results (and above Xmin)
                Inds = ~isnan(Y.(Loc{j})) & X >= Xmin;
                % Plot
                plot(X(Inds),Y.(Loc{j})(Inds)*GammaS./Y.E(Inds),'-s','Color',Col{j},'MarkerEdgeColor','none','MarkerFaceColor',Col{j},'MarkerSize',MSize)
            end
        end

        if PlotMAT1
            % Turn on or off legend visibility
            if j > 4 || [j == 4 && i == 1] || ~PlotOriginal
                HV = 'on';
            else
                HV = 'off';
            end
            
            % Set Marker Fill Color
            if j == 5
                Inds = ~isnan(Y1.(Loc{j})) & X >= Xmin;
                MFC = 'k';
            else
                MFC = 'none';
            end
            
            % Set Marker Edge Color
            if j == 6
                MEC = 'r';
            else
                MEC = 'k';
            end   
            
            % If using TM's E, divide by Y.E (otherwise use new E)
            if AlwaysTME
                plot(X(Inds),Y1.(Loc{j})(Inds)./Y.E(Inds),'-s','Color','k','MarkerEdgeColor',MEC,'MarkerFaceColor',MFC,'MarkerSize',MSize,'HandleVisibility',HV)
                if PlotMAT2
                    plot(X(Inds),Y2.(Loc{j})(Inds)./Y.E(Inds),'-s','Color','k','MarkerEdgeColor',MEC,'MarkerFaceColor',MFC,'MarkerSize',MSize,'HandleVisibility','off')
                end
            else
                plot(X(Inds),Y1.(Loc{j})(Inds)./Y1.E(Inds),'-s','Color','k','MarkerEdgeColor',MEC,'MarkerFaceColor',MFC,'MarkerSize',MSize,'HandleVisibility',HV)
                if PlotMAT2
                    plot(X(Inds),Y2.(Loc{j})(Inds)./Y1.E(Inds),'-s','Color','k','MarkerEdgeColor',MEC,'MarkerFaceColor',MFC,'MarkerSize',MSize,'HandleVisibility','off')
                end
            end
            if j < 5 && PlotOriginal && PlotMAT1
                % Code for accuracy estimation
                bp = zeros(1,size(X,1));
                bp(Inds') = [Y.(Loc{j})(Inds)*GammaS]./[Y1.(Loc{j})(Inds)];
                % Acc is accuracy of MATSim compared to TM
                Acc = [Acc; bp];
            end
        end
    end
    
    % Set tick details, x-axis label, and title
    ytickformat('%.2f'); yticks(0:0.1:1); xticks(Xmin:10:80); set(gca,'TickDir','out'); set(gca,'YGrid','on')
    xlabel('Span (m)')
    title(Title{i})
    
    % From others (setting up ticks correctly)
    % get handle of current, set box property to off and remove background color
    a = gca; set(a,'box','off','color','none');
    % create new, empty axes with box but without ticks
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active, and link axes in case of zooming
    axes(a); linkaxes([a b]);    
    
    % Set axis limits
    ylim([0 1]); xlim([Xmin 80])
    % Y-axis only for the leftmost (first) plot
    if i == 1
        ylabel('E_{SIM}/E_{SIA}')
        yh = get(gca,'ylabel'); % handle to the label object
        p = get(yh,'position'); % get the current position property
        p(1) = 0.9*p(1);          % double the distance,
        % negative values put the label below the axis
        set(yh,'position',p)   % set the new position
    end
    
    % Legend for only the leftmost (first) plot
    if i == 1
        % Set legend with location (the latter auto-generated)
        if PlotMargins
            legend(J([1:length(J)]),'Orientation','horizontal','Position',[0.155677121172981 0.496963062747592 0.701428561380931 0.0242857137322425]);
        else
            legend(J([1:length(J)]));
        end
    end
    
    if PlotMargins
        
        if PlotOriginal
            % Track which of the traffic cases was the highest, for use in Margin Plot
            ESimmax = max([Y.GD'; Y.MD'; Y.DD'; Y.DetD']);
            % Update E with alphasq
            if strcmp(Section{i},'Box')
                alphasq = 0.5;
            else
                alphasq = 0.4;
            end
            EUpdated = 1.5/1.1*(0.7*Y.EQ1 + 0.5*Y.EQ2 + alphasq*Y.Eq);
            % Get Margin for Original
            M = EUpdated./ESimmax'-1;
        end
        
        if PlotMAT1
            % Update E with alphasq (use our E or TM's E) not no gamma 1.1
            if AlwaysTME
                Eupdated1 = 1.5*(0.7*Y.EQ1 + 0.5*Y.EQ2 + alphasq*Y.Eq);
            else
                Eupdated1 = 1.5*(0.7*Y1.EQ1 + 0.5*Y1.EQ2 + alphasq*Y1.Eq);
            end
            ESimmax1 = max([Y1.GD'; Y1.MD'; Y1.DD'; Y1.DetD']);
            M1 = Eupdated1./ESimmax1'-1;
            if PlotCeneriM
                ESimmaxx2 = max([Y1.GD'; Y1.MD'; Y1.DD'; Y1.DetD'; Y1.CD']);
                Mx2 = Eupdated1./ESimmaxx2'-1;
                %ESimmaxx3 = max([Y2.GD'; Y2.MD'; Y2.DD'; Y2.DetD'; Y2.xTCD']);
                %Mx3 = Eupdatedx./ESimmaxx3'-1;
            end
        end
    
        subplot(2,3,i+3)
        fill([0 0 30 50 80 80 0],[0 0.2 0.2 0.1 0.1 0 0],[0.8 0.8 0.8],'EdgeColor','none','LineWidth',1.5);
        hold on
        Inds = M > 0;
        plot(X(Inds),M(Inds),'-s','Color','r','MarkerEdgeColor','none','MarkerFaceColor','r','MarkerSize',MSize)
        % Set tick details
        ytickformat('%.2f'); xticks(Xmin:10:80); set(gca,'TickDir','out'); set(gca,'YGrid','on')
        
        % From others (setting up ticks correctly)
        % get handle of current, set box property to off and remove background color
        a = gca; set(a,'box','off','color','none');
        % create new, empty axes with box but without ticks
        b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[]);
        % set original axes as active, and link axes in case of zooming
        axes(a); linkaxes([a b]);
        
        % Set axis limits, x-axis label
        ylim([0 0.5]); xlim([Xmin 80])
        xlabel('Span (m)')
        % Set y-axis
        if i == 1
            ylabel('Margin')
            yh = get(gca,'ylabel'); % handle to the label object
            p = get(yh,'position'); % get the current position property
            p(1) = 0.9*p(1);          % double the distance,
            % negative values put the label below the axis
            set(yh,'position',p)   % set the new position
        end
        
        title([Title{i}])
         
        if PlotMAT1
            hold on
            Inds = [false true true true true true true true]';
            plot(X(Inds),M1(Inds),'-s','Color','k','MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',MSize)
            if PlotCeneriM
                plot(X(Inds),Mx2(Inds),'-s','Color','k','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',MSize) 
                %plot(X(Inds),Mx3(Inds),'-s','Color','k','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',MSize)
            end
        end
    end
end

% Set figure position
if PlotMargins
    set(gcf,'Position',[50+175*(k-1) -100+50*(k-1) 700 700])
else
    set(gcf,'Position',[50+175*(k-1) 0+50*(k-1) 900 500])
end

% Optional save figure
if SaveFig
    saveas(gcf,['Key Results/' SaveFolder '/' FName SaveSuffix '.png'])
end

% Accuracy to Original
Accuracy = mean(Acc(Acc>0));

end

