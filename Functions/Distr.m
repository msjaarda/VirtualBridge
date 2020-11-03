function [Distr_Excel] = Distr(PDC,TrName,TrTyps,TrAxPerGr,TrTypPri,Location,Year,plotflag)

FaceAlpa = 0.7;

%[TrDistr, P2, A1, B1, a1, b1, A2, B2, a2, b2, p, mu1, mu2, sig1, sig2] = deal(zeros(length(TrTyps),1));
[TrDistr, P2, A1, B1, a1, b1, A2, B2, a2, b2, a3, b3, p1, p2, mu1, mu2, mu3, sig1, sig2, sig3] = deal(zeros(length(TrTyps),1));


pdf_betamixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
                       p*betapdf(x,mu1,sigma1) + (1-p)*betapdf(x,mu2,sigma2);
pdf_betamixture3 = @(x,p1,p2,mu1,mu2,mu3,sigma1,sigma2,sigma3) ...
                       p1*betapdf(x,mu1,sigma1) + p2*betapdf(x,mu2,sigma2) + (1-p1-p2)*betapdf(x,mu3,sigma3);
                   
%Three = ones(length(TrTyps),1);                   
Three = zeros(length(TrTyps),1);  
if plotflag == 1
    figure('units','normalized','outerposition',[0 0 1 1])
    color = cell(length(TrTyps),1);
end

for i = 1:length(TrTyps)
    
    TrTyp = TrTyps(i);
    
    if plotflag == 1
        subplot(4,4,i);
        color{i} = ((13-i)/(13))*(200/255)*[1, 1, 1];
    end
    
% Reinstate in the future... but for now we need to emulate just bimodal
%     try    
%         [x, P2(i), A1(i), B1(i), a1(i), b1(i), A2(i), B2(i), a2(i), b2(i), a3(i), b3(i), p1(i), p2(i), mu1(i), mu2(i), mu3(i), sig1(i), sig2(i), sig3(i)] = PdfweightThree(PDC,TrTyp);
%     catch
%         Three(i) = 0;
%         [x, P2(i), A1(i), B1(i), a1(i), b1(i), A2(i), B2(i), a2(i), b2(i), p(i), mu1(i), mu2(i), sig1(i), sig2(i)] = Pdfweight(PDC,TrTyp);
%     end
    
    [x, P2(i), A1(i), B1(i), a1(i), b1(i), A2(i), B2(i), a2(i), b2(i), p(i), mu1(i), mu2(i), sig1(i), sig2(i)] = Pdfweight(PDC,TrTyp);
    
    if plotflag == 1
        histogram(x,'Normalization','pdf','BinWidth',5,'EdgeColor','none','FaceColor',color{i},'FaceAlpha',FaceAlpa);
    end
    
    xgrid = linspace(0.7*min(x),1.1*max(x),200);
    
    if Three(i) == 0
        pdfgridx = pdf_betamixture(xgrid/1000,1-P2(i)/100,a1(i),a2(i),b1(i),b2(i));
    else
        pdfgridx = pdf_betamixture3(xgrid/1000,p1(i),p2(i),a1(i),a2(i),a3(i),b1(i),b2(i),b3(i));
    end
    
    if plotflag == 1
        hold on
        plot(xgrid,pdfgridx/1000,'-','LineWidth',2)
    
        title(['Type ' TrName{i}])
        xlabel('Weight (kN)')
        ylabel('PDF')
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
        xlim([0 700])
    end
    
    TrDistr(i) = sum(PDC.CLASS == TrTyp)/sum(PDC.CLASS > 0);

end

if plotflag == 1
    sgtitle([Location ' ' num2str(Year) ' Truck Weight Summary']);

    pdfgridr = zeros(1,300);
    xgrid = linspace(0,600,300);
    for i = 1:length(TrTyps)
        if Three(i) == 0
            pdfgrid = pdf_betamixture(xgrid/1000,1-P2(i)/100,a1(i),a2(i),b1(i),b2(i));
        else
            pdfgrid = pdf_betamixture3(xgrid/1000,p1(i),p2(i),a1(i),a2(i),a3(i),b1(i),b2(i),b3(i));
        end
        pdfgridr = pdfgridr + pdfgrid*TrDistr(i);
    end


    % Plot each one plus all weights together (x2), plus TrDistr (bar/pie)

    % Pie chart for distribution
    subplot(4,4,16)

    Labels = {sprintf('%s', TrName{1}) sprintf('%s', TrName{2})...
        sprintf('%s', TrName{3}) sprintf('')...
        sprintf('') sprintf('')...
        sprintf('%s', TrName{7}) sprintf('')...
        sprintf('') sprintf('')...
        sprintf('%s', TrName{11}) sprintf('%s', TrName{12})...
        sprintf('%s', TrName{13})};

    h = pie(TrDistr, Labels);
    colormap([color{1}; color{2}; color{3}; color{4}; color{5}; color{6}; color{7}; color{8};...
        color{9}; color{10}; color{11}; color{12}; color{13}]);
    set(findobj(h, '-property', 'FaceAlpha'), 'FaceAlpha', FaceAlpa);
    title('Distribution of Types')

    % Get prediction using each p, mu1, mu2, sig1, and sig2? convert those to cells
    % Try to do some kind of clustered column...
    subplot(4,4,[14,15])
    % x = PDC.GW_TOT/102;
    % histogram(x,'Normalization','pdf','BinEdges',50:2.5:500,'EdgeColor',[0.3010, 0.7450, 0.9330],'LineWidth',0.5,'FaceColor',[1 1 1]);
    % title('All Trucks > 6t')
    % xlabel('Weight (kN)')
    % ylabel('PDF')
    % set(gca,'ytick',[])
    % set(gca,'yticklabel',[])
    % xlim([0 500])
    % hold on
    % plot(xgrid,pdfgridr/1000,'-','LineWidth',2)




    % TrDistCu = cumsum(TrDistr); 
    % n = 1000000;
    % RanDec = rand(n,1);
    % RanDecx = zeros(n,1);
    % 
    % % Split the RanDecx random decider pie into Truck Types
    % for i = 1:length(TrTyps)
    %     RanDecx(RanDec < TrDistCu(i)) = i;   
    %     RanDec(RanDec < TrDistCu(i)) = 2;         % Just change to something > 1
    % end
    % 
    % RanDecx;
    % Wgt = zeros(n,1); 
    % 
    % for i = 1:length(TrTyps)
    %     Wgt(RanDecx == i) = DoubleBeta(P2(i), A1(i), B1(i), a1(i), b1(i), A2(i), B2(i), a2(i), b2(i), sum(RanDecx == i));
    % end

    count = cell(length(TrTyps),1);
    scaling = 2.5;

    for i = 1:length(TrTyps)
        x = PDC.GW_TOT(PDC.CLASS == TrTyps(i))/102;
        count{i} = histcounts(x,'BinEdges',0:scaling:500);
    end
    % Add Unclassified
    x = PDC.GW_TOT(PDC.CLASS == 0)/102;
    count{length(TrTyps)+1} = histcounts(x,'BinEdges',0:scaling:500);
    
    y = cell2mat(count);
    Su = sum(sum(y));
    y = y/(Su*scaling);

    % figure(2)

    h = bar(y',1,'stacked','FaceAlpha', FaceAlpa,'EdgeColor','none');

    for i = 1:length(TrTyps)
        h(i).FaceColor = color{i};
    end
    % Add Unclassified
    h(length(TrTyps)+1).FaceColor = 'w';
    h(length(TrTyps)+1).EdgeColor = 'k';

    xticks = get(gca,'xtick');
    scaling  = 2.5;
    newlabels = arrayfun(@(x) sprintf('%.0f', scaling * x), xticks, 'un', 0);
    set(gca,'xticklabel',newlabels);

    title('All Trucks > 6t')
    xlabel('Weight (kN)')
    ylabel('PDF')
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    xlim([0 500/scaling])
    hold on
    plot(xgrid/scaling,pdfgridr/1000,'-','LineWidth',2,'Color','r')

end


PlatPct = 0.1*ones(13,1);

% Excel-ready output
Distr_Excel = table(TrName,TrAxPerGr,TrTypPri,TrDistr,PlatPct,P2,A1,B1,a1,b1,A2,B2,a2,b2);





% for i = 1:length(TrTyps)
%     Wgt(RanDecx == i) = DoubleBeta(TrDistr.P2(i), TrDistr.A1(i), TrDistr.B1(i), TrDistr.a1(i), TrDistr.b1(i), TrDistr.A2(i), TrDistr.B2(i), TrDistr.a2(i), TrDistr.b2(i), sum(RanDecx == i));
% end


%hold on
% figure(2)
% histogram(Wgt,150,'Normalization','pdf','BinWidth',2.5,'EdgeColor','none','FaceColor',[0.8 0.8 0.8]);

% % figure(2)
% % 
% % Weightx = DoubleBeta(P2, 0, 1000, a1, b1, 0, 1000, a2, b2, 100000);
% % histogram(Weightx,100,'Normalization','pdf');
% % 
% % xlabel('x')
% % ylabel('Probability Density')



% % Labels = {sprintf('%s %.1f%%', TrNames{1}, TrDistr(1)) sprintf('%s %.1f%%', TrNames{2}, TrDistr(2))...
% %     sprintf('%s %.1f%%', TrNames{3}, TrDistr(3)) sprintf('%s %.1f%%', TrNames{4}, TrDistr(4))...
% %     sprintf('%s %.1f%%', TrNames{5}, TrDistr(5)) sprintf('%s %.1f%%', TrNames{6}, TrDistr(6))...
% %     sprintf('%s %.1f%%', TrNames{7}, TrDistr(7)) sprintf('%s %.1f%%', TrNames{8}, TrDistr(8))...
% %     sprintf('%s %.1f%%', TrNames{9}, TrDistr(9)) sprintf('%s %.1f%%', TrNames{10}, TrDistr(10))...
% %     sprintf('%s %.1f%%', TrNames{11}, TrDistr(11)) sprintf('%s %.1f%%', TrNames{12}, TrDistr(12))...
% %     sprintf('%s %.1f%%', TrNames{13}, TrDistr(13))};


% % % ALL BELOW CAN BE DELETED!!!
% % 
% % 
% % % Select Type (Norm or LogN)
% % Type = 'Norm';
% % 
% % % x = (PDC.GW_TOT(PDC.CLASS == TrTyp)/102)/mean(PDC.GW_TOT(PDC.CLASS == TrTyp)/102);
% % % histogram(x,0:.025:2,'Normalization','pdf');
% % % x = (PDC.GW_TOT(PDC.CLASS == TrTyp)/102)/(max(PDC.GW_TOT(PDC.CLASS == TrTyp)/102)*1.2);
% % % histogram(x,0:.0125:1,'Normalization','pdf');
% % % x = (PDC.GW_TOT(PDC.CLASS == TrTyp)/102);
% % % histogram(x,100,'Normalization','pdf');
% % x = (PDC.GW_TOT(PDC.CLASS == TrTyp)/102)/1000;
% % histogram(x,100,'Normalization','pdf');
% % 
% % if strcmp(Type,'Norm')
% %     pdf_mixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
% %                          p*normpdf(x,mu1,sigma1) + (1-p)*normpdf(x,mu2,sigma2);
% %     pStart = .5;
% %     muStart = quantile(x,[.25 .75]);
% %     sigmaStart = sqrt(var(x) - .25*diff(muStart).^2);
% % else
% %     pdf_mixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
% %                          p*lognpdf(x,mu1,sigma1) + (1-p)*lognpdf(x,mu2,sigma2);
% %     pStart = .5;
% %     muStart = quantile(log(x),[.25 .75]);
% %     sigmaStart = sqrt(var(log(x)) - .25*diff(muStart).^2);
% % end
% % 
% % start = [pStart muStart sigmaStart sigmaStart];
% % 
% % lb = [0 -Inf -Inf 0 0];
% % ub = [1 Inf Inf Inf Inf];
% %                       
% % statset('mlecustom');
% % options = statset('MaxIter',600, 'MaxFunEvals',600);
% % 
% % paramEsts = mle(x, 'pdf',pdf_mixture, 'start',start, ...
% %                           'lower',lb, 'upper',ub, 'options',options);
% %                       
% % xgrid = linspace(0.7*min(x),1.1*max(x),200);
% % pdfgrid = pdf_mixture(xgrid,paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5));
% % hold on
% % plot(xgrid,pdfgrid,'-')
% % %hold off
% % xlabel('x')
% % ylabel('Probability Density')
% % 
% % Weight = DoubleNormal(paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5),100000);
% % histogram(Weight,100,'Normalization','pdf');
% % 
% % mu = paramEsts(2);
% % sig = paramEsts(4);
% % alpha1 = ((1-mu)/(sig^2)-1/mu)*mu^2;
% % beta1 = alpha1*(1/mu-1);
% % 
% % mu = paramEsts(3);
% % sig = paramEsts(5);
% % alpha2 = ((1-mu)/(sig^2)-1/mu)*mu^2;
% % beta2 = alpha2*(1/mu-1);
% % 
% % pdf_betamixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
% %                         p*betapdf(x,mu1,sigma1) + (1-p)*betapdf(x,mu2,sigma2);
% %                     
% % xgrid = linspace(0.7*min(x),1.1*max(x),200);
% % pdfgridx = pdf_betamixture(xgrid,paramEsts(1),alpha1,alpha2,beta1,beta2);
% % hold on
% % plot(xgrid,pdfgridx,'-')                    
% % 
% % 
% % figure(2)
% % 
% % %ScaleFact = max(PDC.GW_TOT(PDC.CLASS == TrTyp)/102)*1.2;
% % ScaleFact = 1000;
% % 
% % x = x*ScaleFact;
% % histogram(x,100,'Normalization','pdf');
% % 
% % paramEsts2 = paramEsts;
% % paramEsts2(2:5) = paramEsts2(2:5)*ScaleFact;
% % 
% % xgrid = xgrid*ScaleFact;
% % pdfgrid = pdf_mixture(xgrid,paramEsts2(1),paramEsts2(2),paramEsts2(3),paramEsts2(4),paramEsts2(5));
% % figure(2), hold on
% % plot(xgrid,pdfgrid,'-')
% % figure(2), hold on
% % plot(xgrid,pdfgridx/1000,'-')
% % 
% % figure(2), hold on
% % Weightx = DoubleBeta(100*(1-paramEsts(1)), 0, 1000, alpha1, beta1, 0, 1000, alpha2, beta2, 100000);
% % %histogram(Weightx,100,'Normalization','pdf');
% % 
% % xlabel('x')
% % ylabel('Probability Density')
% % 
% % 
% % % Now I simply do this for each one!!! output nicely for checking...
% % % convert to spreadsheet for MATSimInput
% % 
% % % I can do the same for the singlebeta

end


