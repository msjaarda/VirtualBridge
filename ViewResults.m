% View Results

% Script to open and manipulate results files
clear, clc, close all, format long g, rng('shuffle'); % Initial commands

% Input File or Folder Name
Folder_Name = 'PlatStud60m';
File_List = dir(['Output/' Folder_Name]);
File_List(1:2) = []; i = 1;

while i <= length(File_List)
    if File_List(i).name(end-4:end) == '.xlsx'
        File_List(i) = [];
    else
        i = i + 1;
    end
end

for i = 1:length(File_List)
    load(['Output/' Folder_Name '/' File_List(i).name])
    if OutInfo.BaseData.RunPlat == 0
        OutInfo.BaseData.PlatSize = 0;
        OutInfo.BaseData.PlatFolDist = 0;
    end
    OInfo(i) = OutInfo;
end

%OInfo = sortrows(OInfo,[OInfo.BaseData.PlatSize OInfo.BaseData.PlatFolDist]);

BD = cat(1,OInfo.BaseData);
Means = cat(1,OInfo.Mean);
% Find the different platooning percentages
PlatPcts = cat(1,OInfo.PlatPct);
UPlatPcts = unique(PlatPcts);

Col{1} = [0 0 0];
Col{2} = [1 0 0];

Pat{1} = ':';
Pat{2} = '-';
Pat{3} = '--';

% Do for each influence line
for i = 1:length(OInfo(1).InfNames)
    
    % Get Influence line name
    ILname = OInfo(1).InfNames{i,1};
    
    for j = 1:length(UPlatPcts)
        
        Meansx = Means(PlatPcts == UPlatPcts(j),i);
        BDx = BD(PlatPcts == UPlatPcts(j),:);
        
        Bunch = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor > 1,:));
        Base = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor == 1,:));
        
        BDx.Ratio = Meansx/Bunch;
        
        BDx = sortrows(BDx,[5 8 9]);
        
        figure(i)
        
        %scatter(BDx.PlatFolDist,BDx.Ratio)
        for k = 2:4
            hold on
            if j == 1
                p(k-1,i) = plot(BDx.PlatFolDist(BDx.PlatSize == k),BDx.Ratio(BDx.PlatSize == k),'Color',Col{j},'LineStyle',Pat{k-1});
            elseif k == 3
                p(4,i) = plot(BDx.PlatFolDist(BDx.PlatSize == k),BDx.Ratio(BDx.PlatSize == k),'Color',Col{j},'LineStyle',Pat{k-1});
            else
                plot(BDx.PlatFolDist(BDx.PlatSize == k),BDx.Ratio(BDx.PlatSize == k),'Color',Col{j},'LineStyle',Pat{k-1})
            end
            title('Effect of Platooning IVD on Load Effect')
            ylabel('Analysis / Base Analysis')
            ylim([0.95 1.25])
            xlabel('Invervehicle Distance (m)')
            xlim([2 10])
            ytickformat('%.2f')
            %UPlatPcts(j)
        end
    end
end

figure(1)
text(6.5,1.23,sprintf('Span: %s Simple Span',Folder_Name(end-2:end)))
text(6.5,1.21,sprintf('IL: %s',OInfo(1).InfNames{1,1}))
text(6.5,1.19,sprintf('TrRate: %.2f',OutInfo.BaseData.TrRate))
text(6.5,1.17,sprintf('Traf: %s','Ceneri 2017'))
text(6.5,1.15,sprintf('Mean of n = 500 maximums'))
text(6.5,1.13,sprintf('500k vehicles simulated'))
legend([p(1,1) p(2,1) p(3,1) p(4,1)],{'2-Tr (20%)','3-Tr (20%)','4-Tr (20%)','40%'},'Location','south','Orientation','horizontal')
legend('boxoff')
figure(2)
text(6.5,1.23,sprintf('Span: %s Simple Span',Folder_Name(end-2:end)))
text(6.5,1.21,sprintf('IL: %s',OInfo(1).InfNames{2,1}))
text(6.5,1.19,sprintf('TrRate: %.2f',OutInfo.BaseData.TrRate))
text(6.5,1.17,sprintf('Traf: %s','Ceneri 2017'))
text(6.5,1.15,sprintf('Mean of n = 500 maximums'))
text(6.5,1.13,sprintf('500k vehicles simulated'))
legend([p(1,2) p(2,2) p(3,2) p(4,2)],{'2-Tr (20%)','3-Tr (20%)','4-Tr (20%)','40%'},'Location','south','Orientation','horizontal')
legend('boxoff')
movegui(figure(1),'northwest')
movegui(figure(2),'north')

% What other phenomenal shall we compare? How about # of platoons 
% Base, 2 tr plat, 3 tr plat, 4 tr plat as x-axis (Ratios on y)

% Could try to develop a procedure for swapping among WIM results...

% Do for each influence line
for i = 1:length(OInfo(1).InfNames)  
    for j = 1:length(UPlatPcts)
        
        Meansx = Means(PlatPcts == UPlatPcts(j),i);
        BDx = BD(PlatPcts == UPlatPcts(j),:);
        
        Bunch = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor > 1,:));
        Base = mean(Meansx(BDx.RunPlat == 0 & BDx.BunchFactor == 1,:));
        
        BDx.Ratio = Meansx/Bunch;
        
        BDx = sortrows(BDx,[5 8 9]);
        
        figure(i+2)
        hold on
        q(j) = plot([1; BDx.PlatSize(BDx.PlatFolDist == 5)],[1; BDx.Ratio(BDx.PlatFolDist == 5)],'Color',Col{j},'LineStyle',Pat{k-1});

        title('Effect of Platoon Size on Load Effect')
        ylabel('Analysis / Base Analysis')
        ylim([1 1.25])
        xlabel('Platoon Size (#)')
        xlim([1 4])
        text(2.5,1.23,sprintf('Span: %s Simple Span',Folder_Name(end-2:end)))
        text(2.5,1.21,sprintf('IL: %s',ILname))
        text(2.5,1.19,sprintf('TrRate: %.2f',OutInfo.BaseData.TrRate))
        text(2.5,1.17,sprintf('Traf: %s','Ceneri 2017'))
        text(2.5,1.15,sprintf('Mean of n = 500 maximums'))
        text(2.5,1.13,sprintf('500k vehicles simulated'))
        ytickformat('%.2f')
        %UPlatPcts(j)
    end
end

figure(1+2)
legend([q(1) q(2)],{'20% Rate','40% Rate'},'Location','west')
legend('boxoff')
figure(2+2)
legend([q(1) q(2)],{'20% Rate','40% Rate'},'Location','west')
legend('boxoff')
movegui(figure(1+2),'northwest')
movegui(figure(2+2),'north')
