% make a histogram of total truck weights, use varying grades of grey
clear
clc
close all
format long g

Year = 2003;
SName{1} = 'Denges';
SName{2} = 'Mattstetten';
SName{3} = 'Gotthard';
x = 0;
PlotType = 'Weight';   % Options are 'LaneDist' or 'Weight'

Num = 3;
   
for i = 1:3
    
    x = x+1;
    %load(strcat(Station,'_',num2str(i),'.mat'))
    load(['PrunedS1 WIM/',SName{i},'/',SName{i},'_',num2str(Year),'.mat']);
    
    % Let the Classify function add the .CLASS column to PD
    PDC = Classify(PD);

    % 1. Disqualification by weight (try under 6 or 10 tonnes)
    PD = PDC(PDC.GW_TOT > 3500,:);
    % 2. Disqualification by Swiss10 Class (exclude 2,3,4,6)
    %PD = PD(PD.CS == 1 | PD.CS == 5 | PD.CS == 7 | PD.CS == 8 | PD.CS == 9 | PD.CS == 10,:);
    
    [TotDaysOpen(x), y] = size(unique(PD.JJJJMMTT));
    [NumTrucks(x), z] = size(PD);
    ADTT(x) = NumTrucks(x)/TotDaysOpen(x);
    AvgWeight(x) = mean(PD.GW_TOT);
    StdWeight(x) = std(PD.GW_TOT);
    Lane = PD.FS == 1;
    Lane1(x) = sum(Lane);
    Lane = PD.FS == 2;
    Lane2(x) = sum(Lane);
    Lane = PD.FS == 3;
    Lane3(x) = sum(Lane);
    Lane = PD.FS == 4;
    Lane4(x) = sum(Lane);
    
    if strcmp(PlotType,'Weight')
        
        [nums{x}, mids{x}] = histcounts(PD.GW_TOT/1000,150,'Normalization','pdf');
        %nums{x} = nums{x}/NumTrucks(x);
        Between = mids{x}>10 & mids{x}<50;

        color = ((Num-i)/(Num))*(200/255)*[1, 1, 1];
        if i == 2018
            color = [0, 1, 0];
        end
        
        j = plot(mids{x}(Between), 100*nums{x}(Between),'Color', color,'LineWidth',1.5);
        %h = histogram(PD.GW_TOT/1000,150,'normalization','pdf','Color',color,'LineWidth',1.5);
        ytickformat('percentage')
        hold on
        
    elseif strcmp(PlotType,'LaneDist')
        
        [nums{x}, mids{x}] = hist(PD.GW_TOT/1000,150);
        nums{x} = nums{x}/NumTrucks(x);
        Between = mids{x}>10 & mids{x}<50;

        color = ((EndY-i)/(EndY-StartY))*(200/255)*[1, 1, 1];
        
        j = plot(mids{x}(Between), 100*nums{x}(Between),'Color', color,'LineWidth',1.5);
        ytickformat('percentage')
        hold on
        
    else
        PDx = [PD.AWT01; PD.AWT02; PD.AWT03; PD.AWT04; PD.AWT05; PD.AWT06; PD.AWT07; PD.AWT08; PD.AWT09];  
        PDx = PDx(PDx > 0);
        [nums{x}, mids{x}]  = histcounts(PDx/1000,150,'Normalization','pdf');
        Between = mids{x}>0 & mids{x}<18; 
        color = ((EndY-i)/(EndY-StartY))*(200/255)*[1, 1, 1];
        if i == 2018
            color = [0, 1, 0];
        end    
        j = plot(mids{x}(Between), 100*nums{x}(Between),'Color', color,'LineWidth',1.5);
        %h = histogram(PD.GW_TOT/1000,150,'normalization','pdf','Color',color,'LineWidth',1.5);
        ytickformat('percentage')
        hold on
    end
    
end

if strcmp(PlotType,'Weight')
    
    title('Evolution of Truck Weights at Monte Ceneri WIM Station')
    xlabel('Truck Weight (tonnes)')
    ylabel('Percentage of Trucks')

elseif strcmp(PlotType,'LaneDist')
    
    title('Lane Distribution at WIM Station')
    xlabel('Truck Weight (tonnes)')
    ylabel('Percentage of Trucks')
    
else
    
    title('Evolution of Axle Weights at Monte Ceneri WIM Station')
    xlabel('Axle Weight (tonnes)')
    ylabel('PDF')

end

x = 1:3;

legend(SName(x));


hold off


%         [nums{x}, mids{x}] = hist(PD.GW_TOT/1000,150);
%         nums{x} = nums{x}/NumTrucks(x);
%         Between = mids{x}>10 & mids{x}<50;
% 
%         color = ((EndY-i)/(EndY-StartY))*(200/255)*[1, 1, 1];
%         j = plot(mids{x}(Between), 100*nums{x}(Between),'Color', color,'LineWidth',1.5);
%         ytickformat('percentage')
%         hold on



% x = [StartY:EndY];
% plot(x,ADTT)
% 
% z = [mean(Lane1) mean(Lane2) mean(Lane3) mean(Lane4)];
% 
% bar(z)
% 

% k = Lane1./(Lane1+Lane2);
% k2 = Lane4./(Lane3+Lane4);
% plot(x,k,x,k2);
% 
% xlim([2003,2018])
% ylim([0.5,1]);

% 
% [nums(x) mids(x)] = hist(PD.GW_TOT/1000, 100);
% nums(x) = nums(x)/NumTrucks(x);
% 
% Between = mids>10 & mids<50;
% 
% plot(mids(Between), 100*nums(Between))
% ytickformat('percentage')
% 
% hold on