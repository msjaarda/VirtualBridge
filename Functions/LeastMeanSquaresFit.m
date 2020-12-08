function [A] = LeastMeanSquaresFit(DMax,FitType,TailP)
%LeastMeanSquaresFit is a function which:
% takes in 1) DMax, Data set of Maximum Observations
%          2) FitType ('GeneralizedExtremeValue', 'Rician', 'Weibull', 'Normal', 'GeneralizedPareto')
%          3) Percentage of Tail to fit
% And gives out A (parameters of dist)

% The issue with the leastmeansquaresfit is that we have to ask ourselves
% in which domain we want to perform the least squares calculation. We can
% do this:
% 1) In the untransformed domain of the CDFs (predicted vs observed)
%       x-axis is load effect
%       y-axis is probability of non-exceedance
% 2) In the probability paper domain, in which 
%       x-axis is load effect
%       y-axis is transformed into standard normal quantiles
%       y-axis is transformed into ____ quantiles (extreme value for ex)

% What is a quantile? A way of expressing percentiles...

% First get the eCDF, DeCDF, and Ranked Data Set, DataR
% Emperical cdf (ecdf) is a function that ranks data points in a sample (DataR) and gives 
% the probability of non-exceedance (DeCDF)... it plots when given no variable

if strcmp(FitType,'ExtremeValue')
    DMax  = -DMax;
end

[DMaxeCDF, DMaxR] = ecdf(DMax); DMaxR = DMaxR';

% Get CutOff index and value
COi = round(length(DMax)*(1-TailP));

if strcmp(FitType,'ExtremeValue')
    DMaxRx = sort(DMax,'descend');
else
    DMaxRx = sort(DMax);
end

COv = DMaxRx(COi);

% First get B, the parameter estimate to start with
B = fitdist(DMax,FitType);

% At this point we take option 2) above and the extreme value
% transformation -log(-log(CDF)) where CDF is prob. of non-exceedance

% We make predictions for the y-value (in ex. prob paper) of each data point in the actual data set, and
% minimize the squared error of these predictions.

Y = -log(-log(DMaxeCDF(COi:end-1)))';

% h = qqplot(DMax);
% Yx = h(1).XData;
% Yx = h(1).YData;
% 
% -log(-log(cdf(FitType,DMaxR(COi:end),param(1),param(2))))
% 
% fn = @(param) sum((-log(-log(cdf(FitType,DMaxR(COi:end),param(1),param(2)))) - Y).^2);
% 
% fn(B.ParameterValues)


% The problem is that B.ParameterValues can be large... we do switch case
switch numel(B.ParameterValues)
    case 2
        % Create function to solve for parameters dist to fit the tail
        fn = @(param) sum((-log(-log(cdf(FitType,DMaxR(COi:end-1),param(1),param(2)))) - Y).^2);
        %fn = @(param) sum((cdf(FitType,DMaxR(COi:end-1),param(1),param(2)) - DMaxeCDF(COi:end-1)').^2);
        %scatter(DMaxR,-log(-log(DMaxeCDF)),7,'k','filled','DisplayName','Daily Max Data');
        
    case 3
        % Create function to solve for parameters of GEV distribution fit to tail
        fn = @(param) sum((cdf(FitType,DMaxR(COi:end-1),param(1),param(2),param(3)) - DMaxeCDF(COi:end-1)').^2);
        fn = @(param) sum((-log(-log(cdf(FitType,DMaxR(COi:end-1),param(1),param(2),param(3)))) - Y).^2);
%     case 4
%         % Create function to solve for parameters of GEV distribution fit to tail
%         fn = @(param) sum((cdf(FitType,DMaxR(COi:end),param(1),param(2),param(3),param(4)) - DMaxeCDF(COi:end)').^2);
end

% Solve for parameters using fminsearch
A =  fminsearch(fn,B.ParameterValues);

end

