 % -------------------- View Platooning Results -------------------- 
% Script to open and manipulate platooning results files 

% Initial commands
clear, clc, format long g, rng('shuffle');
%close all

% Input File or Folder Name
Folder_Name = 'PlatStud60m'; 
%Folder_Name = 'PlatStud456045m';
%Folder_Name = 'PlatStud20m';
%Folder_Name = 'PlatStud608060m';
%Folder_Name = 'Platoon';

File_List = GetFileList(Folder_Name);

% Read in .mat results variables
for i = 1:length(File_List)
    load(['Output/' Folder_Name '/' File_List(i).name])
    if OutInfo.BaseData.RunPlat == 0
        OutInfo.BaseData.PlatSize = 0; OutInfo.BaseData.PlatFolDist = 0;
    end
    OInfo(i) = OutInfo;
    %OInfo.InfNames
end

% Create easier to manage tables and matrices (rather than structure)
BD = cat(1,OInfo.BaseData); Means = cat(1,OInfo.Mean);
% Find the unique platooning percentages for each anlysis
PlatPcts = cat(1,OInfo.PlatPct); UPlatPcts = unique(PlatPcts);

% Predefine colors (red and black)
Col{1} = [0 0 0]; Col{2} = [1 0 0];
% Predefine line styles, or patterns
Pat{1} = ':'; Pat{2} = '-'; Pat{3} = '--';

if length(OutInfo.InfNames) == 1
    BridgeName = Folder_Name(end-6:end);
else
    BridgeName = Folder_Name(end-2:end);
end


load('PLATResults.mat')
%PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/20)
Section = 'Box'; Dist = 'ExFast'; Loc = 'Ceneri2017';
%PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE(i)).(IVD{n})(Span/20)  % (PlatSize).(PlatRate).(AE).(IVD)(Span/20)

AE = 'Mn';
Span = 60;

PlatSize{1} = 'S2'; PlatSize{2} = 'M3'; PlatSize{3} = 'L4';
%2:4; %S2, M3, L4
PlatRate{1} = 'L20'; PlatRate{2} = 'H40'; 
%L20, H40
IVD{1} = 'SMean'; IVD{2} = 'MSMean'; IVD{3} = 'MLMean'; IVD{4} = 'LMean';
%2.5:2.5:10;

% AE Influence Line

% PlatRate Platooning Percentage
for j = 1:2
    % PlatSize Platoon Size
    for k = 1:3
        % IVD Intervehicle Following Distance
        for n = 1:4
            R(k,n,j) = PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE).(IVD{n})(Span/20) / PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE).BaseMean(Span/20);
        end
    end
end




% Plot generation - for each influence line action effect
for i = 1:length(OutInfo.InfNames)
    
    % Get Influence line name
    ILname = OutInfo.InfNames{i};
    % Initialize figure
    figure
    
    % For each platooning percentage
    for j = 1:length(UPlatPcts)
        
        % Get platooning percentage
        PlatPct = UPlatPcts(j);
        PlatPctS = sprintf('%s%%',num2str(PlatPct*100));
        % Get mean results for just this PlatPct and IL
        Meansx = Means(PlatPcts == PlatPct,i);
        % Get BaseData
        BDx = BD(PlatPcts == PlatPct,:);
        
        % Get Bunch and Base data (no Platooning anlysis)
        %if j == 1
        Bunch = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor > 1,:));
        Base = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor == 1,:));
        %end
        
        % Solve for load effect ratios, and sort Base Data for plots
        BDx.Ratio = Meansx/Bunch; BDx = sortrows(BDx,[5 8 9]);
        
        % Platooning sizes
        PSizes = unique(BDx.PlatSize(BDx.PlatSize > 0));
        
        % For each platoon size
        num = 0;
        for k = PSizes'
            num = num + 1;
            hold on
            if j == 1
                p(num) = plot(BDx.PlatFolDist(BDx.PlatSize == k),BDx.Ratio(BDx.PlatSize == k),'Color',Col{j},'LineStyle',Pat{num});
                %plot(BDx.PlatFolDist(BDx.PlatSize == k),R(k-1,:,j)','Color','r','LineStyle',Pat{num});
            elseif k == 3
                p(4) = plot(BDx.PlatFolDist(BDx.PlatSize == k),BDx.Ratio(BDx.PlatSize == k),'Color',Col{j},'LineStyle',Pat{num});
                %plot(BDx.PlatFolDist(BDx.PlatSize == k),R(k-1,:,j)','Color','r','LineStyle',Pat{num});
            else
                plot(BDx.PlatFolDist(BDx.PlatSize == k),BDx.Ratio(BDx.PlatSize == k),'Color',Col{j},'LineStyle',Pat{num})
                %plot(BDx.PlatFolDist(BDx.PlatSize == k),R(k-1,:,j)','Color','r','LineStyle',Pat{num});
            end
            title('Effect of Platooning IVD on Load Effect')
            ylabel('Analysis / Base Analysis')
            ylim([0.95 1.25])
            xlabel('Invervehicle Distance (m)')
            xlim([2 10])
            ytickformat('%.2f')
        end

    end
    text(6.5,1.23,sprintf('Structure: %s',BridgeName))
    text(6.5,1.21,sprintf('IL: %s',ILname))
    text(6.5,1.19,sprintf('TrRate: %.2f',OutInfo.BaseData.TrRate))
    text(6.5,1.17,sprintf('Traf: %s','Ceneri 2017'))
    text(6.5,1.15,sprintf('Mean of n = 500 maximums'))
    text(6.5,1.13,sprintf('500k vehicles simulated'))
    legend([p(1) p(2) p(3) p(4)],{'2-Tr (20%)','3-Tr (20%)','4-Tr (20%)','40%'},'Location','south','Orientation','horizontal')
    %legend([p(1) p(2) p(3)],{'2-Tr (20%)','3-Tr (20%)','4-Tr (20%)'},'Location','south','Orientation','horizontal')
    legend('boxoff')
    movegui(gcf,'northwest')
end

% add 3.23 following distance to plots 1 and 2?
% Could try to develop a procedure for swapping among WIM results...

% Plot generation - for each influence line action effect
for i = 1:length(OutInfo.InfNames)
    
    % Get Influence line name
    ILname = OutInfo.InfNames{i};
    % Initialize figure
    figure
    
    for j = 1:length(UPlatPcts)
        
        Meansx = Means(PlatPcts == UPlatPcts(j),i);
        BDx = BD(PlatPcts == UPlatPcts(j),:);
        
        Bunch = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor > 1,:));
        Base = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor == 1,:));
        
        BDx.Ratio = Meansx/Bunch;
        
        BDx = sortrows(BDx,[5 8 9]);
        
        num = 0;
        for k = [5 7.5]
            num = num+1;
            hold on
            plot([1; BDx.PlatSize(BDx.PlatFolDist == k)],[1; BDx.Ratio(BDx.PlatFolDist == k)],'Color',Col{j},'LineStyle',Pat{num},'Marker','*');
        end

    end
    title('Effect of Platoon Size on Load Effect')
    ylabel('Analysis / Base Analysis')
    ylim([1 1.25])
    xlabel('Platoon Size (#)')
    xlim([1 4])
    set(gca, 'XTick', 1:4)
    text(2.5,1.235,sprintf('Structure: %s',BridgeName))
    text(2.5,1.22,sprintf('IL: %s',ILname))
    text(2.5,1.205,sprintf('TrRate: %.2f',OutInfo.BaseData.TrRate))
    text(2.5,1.19,sprintf('Traf: %s','Ceneri 2017'))
    text(2.5,1.175,sprintf('Mean of n = 500 maximums'))
    text(2.5,1.16,sprintf('500k vehicles simulated'))
    legend({'5 m IVD (20%)','7.5 m IVD (20%)','5 m IVD (40%)','7.5 m IVD (40%)'},'Location','west')
    legend('boxoff')
    movegui(gcf,'north')
end



% % Initialize figure
% figure
