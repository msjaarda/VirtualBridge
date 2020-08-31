function [x,y] = AxleStats(PDC,TrAxPerGr,TrTyps,SName,Year,Plot)
% AXLESTATS This function takes in a processed data WIM table with classification PDC and
% summarizes its axles.

% We could go about this using classified vehicle data... or do a new
% search on all the vehicles for proximity to next axle.

% Start with Classified only
NumTrTyp = length(TrTyps);
TrTypNumAxPerGr = cell(NumTrTyp,1);
x = cell(3,1);

% Tonnes to kN Conversion [/100 or /102 (to use g = 9.8)]
TtkN = 102;
% Classified Only (only applies to All Axles - others are class only always)
ClassOnly = true;

if width(PDC) > 35
    if sum(strcmp('Head',PDC.Properties.VariableNames)) > 0
        shift = 13;
    else
        shift = 13 + 10;
    end
else
    shift = 13;
end

if Plot == 1
    FaceAlpa = 0.7;
    FontSize = 10;
    Xmax = 400;
    AName{1} = 'Single'; AName{2} = 'Tandem'; AName{3} = 'Tridem';
    fig = get(groot,'CurrentFigure');
    if ~isempty(fig) && strcmp(fig.Name,'Axle Weights')
        sgtitle([SName ' ' 'Comparison' ' Truck Axle Weights']);
        EdgeCo = 'r'; FontCo = 'w';
        delete(findobj(gcf,'Type','Text'))
    else
        figure('Name','Axle Weights','NumberTitle','off','units','normalized','outerposition',[0 0 1 1])
        sgtitle([SName ' ' num2str(Year) ' Truck Axle Weights']);
        EdgeCo = 'k'; FontCo = 'k';
    end
end

for i = 1:NumTrTyp 
    TrTypNumAxPerGr{i} = arrayfun(@(x) mod(floor(TrAxPerGr(i)/10^x),10),floor(log10(TrAxPerGr(i))):-1:0);
end

for k = 1:3
    x{k} = [];
    for i = 1:NumTrTyp 
        m = cumsum(TrTypNumAxPerGr{i});
        for j = 1:length(TrTypNumAxPerGr{i})
            if TrTypNumAxPerGr{i}(j) == k
                Range = m(j);
                Range = Range + shift;
                x{k} = [x{k}; sum(PDC{PDC.CLASS == TrTyps(i),Range-k+1:Range},2)/TtkN;];
            end
        end
    end
    
    N(k) = length(x{k});
    if Plot == 1
        subplot(2,2,k);
        hold on
        histogram(x{k},'Normalization','pdf','BinWidth',2.5,'EdgeColor',EdgeCo,'FaceColor',((4-k)/3)*[.8 .8 .8],'FaceAlpha',FaceAlpa);
        title([AName{k} ' Axles'])
        xlabel('Weight (kN)')
        xlim([0 Xmax])
        ylabel('PDF')
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
        c = ylim;
        % Put statistics onto histogram
        text(275,c(2)*13/16,sprintf('N'),'FontSize',FontSize,'Color',FontCo)
        text(275,c(2)*12/16,'\mu','FontSize',FontSize,'Color',FontCo)
        text(275,c(2)*11/16,'\sigma','FontSize',FontSize,'Color',FontCo)
        text(275,c(2)*10/16,sprintf('F_{95}'),'FontSize',FontSize,'Color',FontCo)
        text(275,c(2)*9/16,sprintf('F_{99}'),'FontSize',FontSize,'Color',FontCo)
        text(275,c(2)*8/16,sprintf('F_{99.99}'),'FontSize',FontSize,'Color',FontCo)
        text(300,c(2)*13/16,sprintf('= %i',N(k)),'FontSize',FontSize,'Color',FontCo)
        text(300,c(2)*12/16,sprintf('= %.1f kN',mean(x{k})),'FontSize',FontSize,'Color',FontCo)
        text(300,c(2)*11/16,sprintf('= %.1f kN',std(x{k})),'FontSize',FontSize,'Color',FontCo)
        text(300,c(2)*10/16,sprintf('= %.1f kN',prctile(x{k},95)),'FontSize',FontSize,'Color',FontCo)
        text(300,c(2)*9/16,sprintf('= %.1f kN',prctile(x{k},99)),'FontSize',FontSize,'Color',FontCo)
        text(300,c(2)*8/16,sprintf('= %.1f kN',prctile(x{k},99.99)),'FontSize',FontSize,'Color',FontCo)

    end
end

% All
y = [];

% Notice that All Axles is not just those that are classified
% Add that option here:
if ClassOnly
    PDC = PDC(PDC.CLASS > 0,:);
end

for i = shift+1:shift+9
    y = [y; PDC{PDC{:,i} > 10,i}/TtkN];
end

N(k+1) = length(y);

if Plot == 1
    subplot(2,2,k+1);
    hold on
    histogram(y,'Normalization','pdf','BinWidth',1.5,'EdgeColor',EdgeCo,'FaceColor',[.36 .51 .83],'FaceAlpha',FaceAlpa);
    title('All Axles')
    xlabel('Weight (kN)')
    xlim([0 180])
    ylabel('PDF')
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    
    c = ylim;
  
    text(110,c(2)*13/16,sprintf('N'),'FontSize',FontSize,'Color',FontCo)
    text(135,c(2)*13/16,sprintf('= %i',N(k+1)),'FontSize',FontSize,'Color',FontCo)
    text(110,c(2)*12/16,'\mu','FontSize',FontSize,'Color',FontCo)
    text(135,c(2)*12/16,sprintf('= %.1f kN',mean(y)),'FontSize',FontSize,'Color',FontCo)
    text(110,c(2)*11/16,'\sigma','FontSize',FontSize,'Color',FontCo)
    text(135,c(2)*11/16,sprintf('= %.1f kN',std(y)),'FontSize',FontSize,'Color',FontCo)
    text(110,c(2)*10/16,sprintf('F_{95}'),'FontSize',FontSize,'Color',FontCo)
    text(135,c(2)*10/16,sprintf('= %.1f kN',prctile(y,95)),'FontSize',FontSize,'Color',FontCo)
    text(110,c(2)*9/16,sprintf('F_{99}'),'FontSize',FontSize,'Color',FontCo)
    text(135,c(2)*9/16,sprintf('= %.1f kN',prctile(y,99)),'FontSize',FontSize,'Color',FontCo)
    text(110,c(2)*8/16,sprintf('F_{99.99}'),'FontSize',FontSize,'Color',FontCo)
    text(135,c(2)*8/16,sprintf('= %.1f kN',prctile(y,99.99)),'FontSize',FontSize,'Color',FontCo)
end

end