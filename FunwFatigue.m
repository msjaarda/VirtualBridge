% Fatigue
% use https://www.mathworks.com/help/signal/ref/rainflow.html
% Script loads a variable, R, which is from GetMaxLE of MATSim
% Should figure out a way to optionally save R when Fatigue Analysis is
% chosen by MATSim user. Alternatively, a fatigue analysis can be done from
% inside GetMaxLE and saved as a Fatigue Output variable... just ideas.

clear, clc, close all
load('FatigueOutput\MpHistory_R.mat')

% Convert Moment, kNm, to Stress, MPa
ScalingFactor = 20;
R = R/ScalingFactor;

% Display a histogram of cycles as a function of cycle average and cycle range
rainflow(R)

n = 1000;
%n = length(R);

figure
plot(1:n,R(1:n),'r-')

title('Raw Stress History')
xlabel('Cycle Number')
xlim([0 n])
ylabel('Stress (MPa)')

[c,hist,edges,rmm,idx] = rainflow(R);
T = array2table(c,'VariableNames',{'Count','Range','Mean','Start','End'});

hold on
plot(idx,R(idx),'bo')

figure
histogram('BinEdges',edges','BinCounts',sum(hist,2),'EdgeColor',[0 0 0],'LineWidth',1,'FaceColor',[.6 .6 .6])
xlabel('Stress Range (MPa)')
ylabel('Cycle Counts PDF')

% Draw SN Curve... m = 3, k = 5, and shift until damage = 1
figure
% Start with FAT80
CAT = 80;
n2 = 2E6; s2 = CAT;                                 % 2 is C (Class Value)
n1 = 1E4; s1 = (s2^(3)*n2/n1)^(1/3);                % 1 is leftmost
n3 = 5E6; s3 = (s2^(3)*n2/n3)^(1/3); % = 0.737*s2;  % 3 is D (Knee Point)
n4 = 1E8; s4 = (s3^(5)*n3/n4)^(1/5); % = 0.549*s3;  % 4 is L (Cutoff)
n5 = 1E10; s5 = s4;                                 % 5 is rightmost

Stress = [s1 s2 s3 s4 s5];
NumC = [n1 n2 n3 n4 n5];
plot(NumC,Stress,'k-')
set(gca, 'YScale', 'log', 'XScale', 'log')
hold on
xlim([1E4 1E9])
ylim([1E1 1E3])
ylabel('Stress Range (MPa)')
xlabel('Number of Cycles (#)')

% Calculate damage from R
% Take each cycle... count half cycles as full cycles... and compute damage
% Start by assuming FAT80
% Initialize with zeros
T.Life = zeros(height(T),1);
% Assume m = 3
T.Life = s2^3*n2./(T.Range.^3);
% Assume k = 5 for those that exceed kneepoint
T.Life(T.Life > n3) = s3^5*n3./(T.Range(T.Life > n3).^5);
% Take care of those exceeding cutoff
T.Life(T.Life > n4) = Inf;
T.Damage = T.Count.*T.Range./T.Life;

fprintf('\nTotal Damage: %.2f %% of Fatigue Life\n\n',sum(T.Damage)*100)

% Now we shift until Damage = 1, and see what FAT CAT we are AT
CatOLD = CAT;
while sum(T.Damage) > 1.0001 || sum(T.Damage) < 0.9999
    if sum(T.Damage) > 1
        CatNEW = CatOLD + 0.15*abs(100-sum(T.Damage)*100);
    else
        CatNEW = max(CatOLD - 0.15*abs(100-sum(T.Damage)*100),0);
    end
    s2 = CatNEW;  
    s3 = 0.737*s2;
    
    % Assume m = 3
    T.Life = s2^3*n2./(T.Range.^3);
    % Assume k = 5 for those that exceed kneepoint
    T.Life(T.Life > n3) = s3^5*n3./(T.Range(T.Life > n3).^5);
    % Take care of those exceeding cutoff
    T.Life(T.Life > n4) = Inf;
    T.Damage = T.Count.*T.Range./T.Life;
    CatOLD = CatNEW;
    fprintf('\nTotal Damage: %.4f %% of Fatigue Life\tCAT %.2f',sum(T.Damage)*100, CatNEW)
    if CatNEW == 0
        fprintf('\nFailed to find solution to fatigue curve\n\n')
        break
    end
end
fprintf('\nDONE\n\n')





