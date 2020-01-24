% ------------------------------------------------------------------------
%                            MATSim2019forWIM
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects
%       - To be used with MATSimInput spreadsheet for Inf Lines

% Initial commands
tic, clear, clc, close all, format long g, rng('shuffle'); st = now;

% Input File Name
InputFile = 'Input/MATSimInputxTes.xlsx';

% Read simulation data from Input File
[BaseData,LaneData,~,~] = ReadInputFile(InputFile); OverMax = [];

% Get Influence Line Details
[InfLanes,InfNames,UniqInf,UniqInfs,UniqInfi,Num.InfCases,Infx,Infv,IntInfv,MaxInfv] = GetInfLines(LaneData,BaseData);

% WIM File
SName = 'Ceneri'; Stage2Prune = false; ClassOnly = false; NumAnalyses = 100; Year = 2011:2018; %i = 1;

% Do for different years
for i = 1:length(Year)
    
    % Load WIM File [OR VWIM File]
    load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year(i)),'.mat']);
    %load('WIM_Jan14 1130.mat');

    % Only needs to be done to WIM
    
    % Add row for Class, Daytime, and Daycount
    PDC = Classify(PD); PDC = Daytype(PDC,Year(i)); clear('PD')
    
    % We treat each station separately [edit Stations(1) to Stations(2)]
    Stations = unique(PDC.ZST); Station = Stations(1);
    
    PDCx = PDC(PDC.ZST == Station,:); clear('PDC')
    
    if Stage2Prune
        PDCx = PruneWIM2(PDCx,0);
    end
    
    if ClassOnly
        PDCx(PDCx.CLASS == 0,:) = [];
    end
    
    % Convert PDC to AllTrAx
    [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Infx(end)));
    
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1));

    % Do analysis multiple times... deleting top vehicles each time
    for k = 1:NumAnalyses
        
        for t = 1:Num.InfCases
            % Subject Influence Line to Truck Axle Stream
            [MaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Infv,InfLanes,[80 20],BaseData.RunDyn,t,UniqInfs,UniqInfi);
            % Record Maximums
            OverMax = [OverMax; [t, Year(i), MaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
        end
        
        % Get ESIA from function
        ESIA = GetESia(IntInfv,MaxInfv,InfLanes,UniqInfs);
        
        %T = Apercu(PDCx,[num2str(Year(i)) ' ' SName ' Station ' num2str(Station)],Infx,Infv,BrStInd,TrLineUp,MaxLE/ESIA,DLF);
        
        % Delete vehicle entries from TrLineUp
        TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Infx(end),:) = [];
        % Set Axles to zero in AllTrAx (can't delete because indices are locations
        AllTrAx(BrStInd:BrStInd + Infx(end),:) = 0;
        
        % Optional commands to save the figures generated
        %saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station)])
        %saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station) '.png'])
        
    end

end

% Get simulation time
Time = GetSimTime();

% Convert Results to Table
OverMAXT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

% Create box plot array
for i = 1:length(Year)
    D(:,i) = OverMAXT.MaxLE(OverMAXT.Year == Year(i));
end

% Optional commands to save the table generated
%save(['Key Results/RealWIM on Fornaci/' num2str(Station) '_MaxLEs'],'OverMAXT')

% Optional boox and whisker plot
% boxplot(D,Year)
% hold on
% plot([0 9],[ESIA ESIA],'k')
% text(1,ESIA-2000,sprintf('E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','r')
% hold on
% plot([0 9],.72*[ESIA ESIA],'-.k')
% text(1,0.72*ESIA+1000,sprintf('72%% E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','k')
% ylim([5000 25500])
% ytickformat('%g')
% curtick = get(gca, 'YTick');
% set(gca, 'YTickLabel', cellstr(num2str(curtick(:))));
% xlabel('Year')
% ylabel('Moment (kNm)')
% title('Ceneri 409 Max LEs | 40 m Simple Span')

boxplot(D/ESIA,Year)
hold on
plot([0 9],[1 1],'k')
text(1,1-0.05,sprintf('E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','r')
hold on
plot([0 9],.72*[1 1],'-.k')
text(1,0.72*1+0.05,sprintf('72%% E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','k')
ylim([0 1])
ytickformat('%g')
xlabel('Year')
ylabel('Moment (kNm)')
title('Ceneri 408 Max LEs [100/Year] | Fornaci')

% figure
% scatter(OverMAXT.Year,OverMAXT.MaxLE,'+k')
% hold on
% plot([OverMAXT.Year(1)-1 OverMAXT.Year(end)+1],[ESIA ESIA],'k')
% text(OverMAXT.Year(1),ESIA+1000,sprintf('E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','r')
% hold on
% plot([OverMAXT.Year(1)-1 OverMAXT.Year(end)+1],.72*[ESIA ESIA],'-.k')
% text(OverMAXT.Year(1),0.72*ESIA+1000,sprintf('72%% E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','k')
% ylim([0 28000])
% ytickformat('%g')
% curtick = get(gca, 'YTick');
% set(gca, 'YTickLabel', cellstr(num2str(curtick(:))));
% xlabel('Year')
% ylabel('Moment (kNm)')
% title('Ceneri [409] Max LEs | 40 m Simple Span')
% 
% fprintf('Percent of ESIA = %.2f\n\n',MaxLE/ESIA)
