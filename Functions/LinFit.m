function [LinFit_Excel] = LinFit(PDC,TrName,TrTyps,TrAxPerGr,TrTypPri,Location,Year,plotflag)
% This function used in the MATSim input file pipeline

% Plot Stuff
FaceAlpa = 0.7;
if plotflag == 1
    figure('units','normalized','outerposition',[0 0 1 1])
    g = 1;
end

NumTrTyp = length(TrTyps);
[TrTypNumAxPerGr, TrTypPriority] = deal(cell(NumTrTyp,1));
[TrTypNumAx, TrTypNumAxGr] = deal(zeros(NumTrTyp,1));

LinFit_Excel = NaN(NumTrTyp,4*2);
LinFit_Excel(:,1) = ones(length(TrTyps),1);
LinFit_Excel(:,2) = zeros(length(TrTyps),1);

for i = 1:NumTrTyp    % For each truck type
    TrTypNumAxPerGr{i} = arrayfun(@(x) mod(floor(TrAxPerGr(i)/10^x),10),floor(log10(TrAxPerGr(i))):-1:0);
    TrTypPriority{i} = arrayfun(@(x) mod(floor(TrTypPri(i)/10^x),10),floor(log10(TrTypPri(i))):-1:0);
    TrTypNumAx(i) = sum(TrTypNumAxPerGr{i});
    TrTypNumAxGr(i) = length(TrTypNumAxPerGr{i});
    y = 0;
    m = cumsum(TrTypNumAxPerGr{i});
    for j = 1:TrTypNumAxGr(i)-1   % For each axle group (except the first one)
        if plotflag == 1
            subplot(5,5,g);
        end
        
        % Figure out which indexes are for x, and which are for y
        
        % Now do x... it is harder
        
        if j == 1   % For the first one x:
           x = PDC.GW_TOT(PDC.CLASS == TrTyps(i))/102;
           xLabel = 'Total Weight';
        else    % Then after that x adds what y was last time
           x = x - y; 
           xLabel = [xLabel ' - ' yLabel];
        end
        
        % Start with y... it is easier
        % It is the axle group in question
        Range = m(TrTypPriority{i}(j)-1)+1:m(TrTypPriority{i}(j));
        Range = Range + find(string(PDC.Properties.VariableNames) == "AX");
        % modified 7/4/21 to including smart column label finding.

        y = PDC{PDC.CLASS == TrTyps(i),Range}/102;
        y = sum(y,2);
        yLabel = ['Axle Group ' num2str(TrTypPriority{i}(j))];
        
        if plotflag == 1
            dscatter(x,y)
        end

        coefficients = polyfit(x,y,1);
        
        if plotflag == 1
            xFit = linspace(min(x), max(x), 1000);
            yFit = polyval(coefficients , xFit);
            hold on;
            plot(xFit, yFit, 'r-', 'LineWidth', 2);
            
            g = g+1;
        
            title(['Type ' TrName{i}])
            xlabel([xLabel ' (kN)'])
            ylabel([yLabel ' (kN)'])
            xlim([0 700])
            ylim([0 500])
        
        end
        
        LinFit_Excel(i,2*TrTypPriority{i}(j)-1) = coefficients(1);
        LinFit_Excel(i,2*TrTypPriority{i}(j)) = coefficients(2);
        
        
    end
    
end

if plotflag == 1
    sgtitle([Location ' ' num2str(Year) ' Truck Axle Group Weight Linear Relationships']);
end

LinFit_Excel = array2table(LinFit_Excel);
LinFit_Excel.Properties.VariableNames = {'m1' 'b1' 'm2' 'b2' 'm3' 'b3' 'm4' 'b4' };





% % coefficients2 = [0.807, -27.9];
% % yFit = polyval(coefficients2 , xFit);
% % hold on;
% % plot(xFit, yFit, 'bla-', 'LineWidth', 2);
% % 
% % N = sum(PDC.CLASS == TrTyps(2));
% % 
% % figure(2)
% % 
% % x = PDC.AWT02(PDC.CLASS == TrTyps(2))/102;
% % y = PDC.AWT03(PDC.CLASS == TrTyps(2))/102;
% % 
% % dscatter(x,y)
% % 
% % coefficients = polyfit(x,y,1);
% % 
% % xFit = linspace(min(x), max(x), 1000);
% % yFit = polyval(coefficients , xFit);
% % hold on;
% % plot(xFit, yFit, 'r-', 'LineWidth', 2);
% % 
% % % xlim([0 300])
% % % ylim([0 150])


end