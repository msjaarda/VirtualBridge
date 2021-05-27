function [BetAx_Excel] = BetAx(PDC,TrName,TrTyps,TrAxPerGr,TrTypPri,SName,Year,plotflag)
% This function used in the MATSim input file pipeline


shift = find(string(PDC.Properties.VariableNames) == "W1_2")-1;

% Replaced the below with the above on 7/4/21
% if width(PDC) > 35
%     if sum(strcmp('Head',PDC.Properties.VariableNames)) > 0
%         shift = 23;
%     else
%         shift = 23 + 10;
%     end
% else
%     shift = 23;
% end


% Plot Stuff
FaceAlpha = 0.7;
color = cell(length(TrTyps),1);
if plotflag == 1
    g = 1;
    fig = get(groot,'CurrentFigure');
    flag = true;
    if ~isempty(fig) && strcmp(fig.Name,'Distances Between Axles')
        sgtitle([SName ' ' 'Comparison' ' Distances Between Axles']);
        EdgeCo = 'b'; %FontCo = 'w';
        EdgeAl = 0.1;
        delete(findobj(gcf,'Type','Line'))
        LinCo = 'none';
        FaceAlpha = 0.85;
    else
        figure('Name','Distances Between Axles','NumberTitle','off','units','normalized','outerposition',[0 0 1 1])
        sgtitle([SName ' ' num2str(Year) ' Truck Axle Group Wheelbases']);
        EdgeCo = 'none'; %FontCo = 'k';
        LinCo = 'r';
        EdgeAl = 1;
    end
end

NumTrTyp = length(TrTyps);
[TrTypNumAxPerGr, TrTypPriority] = deal(cell(NumTrTyp,1));
[TrTypNumAx, TrTypNumAxGr] = deal(zeros(NumTrTyp,1));

% Check if we can do this as NaN
BetAx_Excel = NaN(NumTrTyp,4*3);

for i = 1:NumTrTyp    % For each truck type
    TrTypNumAxPerGr{i} = arrayfun(@(x) mod(floor(TrAxPerGr(i)/10^x),10),floor(log10(TrAxPerGr(i))):-1:0);
    TrTypPriority{i} = arrayfun(@(x) mod(floor(TrTypPri(i)/10^x),10),floor(log10(TrTypPri(i))):-1:0);
    TrTypNumAx(i) = sum(TrTypNumAxPerGr{i});
    TrTypNumAxGr(i) = length(TrTypNumAxPerGr{i});
    m = cumsum(TrTypNumAxPerGr{i});
    color{i} = ((13-i)/(13))*(200/255)*[1, 1, 1];
    
    for j = 1:TrTypNumAxGr(i)-1   % For each axle group (except the first one)
        if plotflag == 1
            subplot(5,5,g);
        end
        % Find out between which two axles we should be plotting...
        Ind = m(j) + shift;
        
        if sum(PDC.CLASS == TrTyps(i)) > 20
            x = PDC{PDC.CLASS == TrTyps(i),Ind}/100;

            if plotflag == 1
                histogram(x,'Normalization','pdf','BinWidth',0.05,'EdgeColor',EdgeCo,'FaceColor',color{i},'FaceAlpha',FaceAlpha,'EdgeAlpha',EdgeAl);
            end


            PD = betafit(x/10);

            if plotflag == 1

                xgrid = linspace(0,1,100);
                ygrid = betapdf(xgrid,PD(1),PD(2));

                hold on
                plot(xgrid*10,ygrid/10,'-','LineWidth',2,'Color',LinCo)

                g = g+1;
                title(['Type ' TrName{i}])
                xlabel(['Axle ' num2str(m(j)) ' to '  num2str(m(j)+1) ' (m)'])
                xlim([0 10])
                ylabel('PDF')
                set(gca,'ytick',[])
                set(gca,'yticklabel',[])
            end

            BetAx_Excel(i,(j-1)*4+1) = 0;
            BetAx_Excel(i,(j-1)*4+2) = 10;
            BetAx_Excel(i,(j-1)*4+3) = PD(1);
            BetAx_Excel(i,(j-1)*4+4) = PD(2);

    %         A = 3.6;
    %         B = 7.2;
    %         PD(1) = 1.26;
    %         PD(2) = 0.85;
    %         ygrid = betapdf(xgrid,PD(1),PD(2));
    %         hold on
    %         plot(A+xgrid*(B-A),ygrid/(B-A),'-','LineWidth',2)


        end    
    end
end

BetAx_Excel = array2table(BetAx_Excel);
BetAx_Excel.Properties.VariableNames = {'A1' 'B1' 'a1' 'b1' 'A2' 'B2' 'a2' 'b2' 'A3' 'B3' 'a3' 'b3' };

% if flag
%     delete(findobj(gcf,'Type','Line'))
%     
% end

% CONFIRMATION
% data = BetAx_Excel.A2(13) + (BetAx_Excel.B2(13)-BetAx_Excel.A2(13))*betarnd(BetAx_Excel.a2(13),BetAx_Excel.b2(13),100000,1);
% hold on
% histogram(data,'Normalization','pdf','BinWidth',0.05,'EdgeColor','none','FaceColor',[.9 .9 .9],'FaceAlpha',FaceAlpa);

end


