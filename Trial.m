% -------------------- View Platooning Results -------------------- 
% Script to open and manipulate platooning results files 

% Initial commands
clear, clc, format long g, rng('shuffle');
close all

% Predefine colors (red and black)
Col{1} = [0 0 0]; Col{2} = [1 0 0];
% Predefine line styles, or patterns
Pat{1} = ':'; Pat{2} = '-'; Pat{3} = '--';

load('PLATResults.mat')
%PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/20)
Section = 'Box'; Dist = 'ExFast'; Loc = 'Ceneri2017';
%PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE(i)).(IVD{n})(Span/20)  % (PlatSize).(PlatRate).(AE).(IVD)(Span/20)

AE = 'Mp'; Span = 60;
ILname = [AE num2str(Span)];
PlatSize{1} = 'S2'; PlatSize{2} = 'M3'; PlatSize{3} = 'L4';
PlatSizeNum = 2:4;
PlatRate{1} = 'L20'; PlatRate{2} = 'H40';
PlatRateNum = [0.2 0.4];
IVD{1} = 'SMean'; IVD{2} = 'MSMean'; IVD{3} = 'MLMean'; IVD{4} = 'LMean';
IVDnum = 2.5:2.5:10;

% PlatRate Platooning Percentage
% for j = 20:20:80
%     % PlatSize Platoon Size
%     for k = 1:size(PlatSize,2)
%         % IVD Intervehicle Following Distance
%         for n = 1:size(IVD,2)
%             Rx(k,n,j) = PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE).(IVD{n})(Spanx/20) / PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE).BaseMean(Spanx/20);
%         end
%     end
% end


% PlatRate Platooning Percentage
for j = 1:size(PlatRate,2)
    % PlatSize Platoon Size
    for k = 1:size(PlatSize,2)
        % IVD Intervehicle Following Distance
        for n = 1:size(IVD,2)
            R(k,n,j) = PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE).(IVD{n})(Span/20) / PLAT.(Section).(Dist).(Loc).(PlatSize{k}).(PlatRate{j}).(AE).BaseMean(Span/20);
        end
    end
end


% FIGURE 1 -- EFFECT OF PLATOONING IVD ON LOAD EFFECT
figure     % Initialize figure
% Set visibility for legend
HV = repmat({'on'},1,5); HV{4} = 'off'; HV{6} = 'off';

% For each platooning percentage
for j = 1:size(PlatRate,2)   
    % For each platoon size
    for k = 1:size(PlatSize,2)
        hold on
        plot(IVDnum,R(k,:,j)','Color',Col{j},'LineStyle',Pat{k},'LineWidth',1,'HandleVisibility',HV{(j-1)*size(PlatSize,2)+k});
    end
end
title('Effect of Platooning IVD on Load Effect')
ylabel('Analysis / Base Analysis')
ylim([0.95 1.25])
xlabel('Invervehicle Distance (m)')
xlim([2 10])
ytickformat('%.2f')
text(6.5,1.21,sprintf('IL: %s',ILname))
text(6.5,1.19,sprintf('TrRate: %.1f%%',12))
text(6.5,1.17,sprintf('Traf: %s',Loc))
text(6.5,1.15,sprintf('Mean of n = 500 maximums'))
text(6.5,1.13,sprintf('50k vehicles simulated'))
legend({'2-Tr (20%)','3-Tr (20%)','4-Tr (20%)','40%'},'Location','south','Orientation','horizontal')
legend('boxoff')
movegui(gcf,'northwest')

% add 3.23 following distance to plots 1 and 2?
% Could try to develop a procedure for swapping among WIM results...


% FIGURE 2 -- EFFECT OF PLATOON SIZE  ON LOAD EFFECT
figure        % Initialize figure
% Set visibility for legend
clear HV
HV = repmat({'on'},1,4); HV{3} = 'off';

% For each platooning percentage
for j = 1:size(PlatRate,2)
    % For some of the intervehicle distances   
    for n = 1:2
        hold on
        plot([1; PlatSizeNum'],[1; R(:,n,j)],'Color',Col{j},'LineStyle',Pat{n},'Marker','*','HandleVisibility',HV{(j-1)*2+n},'LineWidth',1);
    end
end
title('Effect of Platoon Size on Load Effect')
ylabel('Analysis / Base Analysis')
ylim([0.95 1.25])
xlabel('Platoon Size (#)')
xlim([1 4])
set(gca, 'XTick', 1:4)
text(1.5,1.21,sprintf('IL: %s',ILname))
text(1.5,1.19,sprintf('TrRate: %.1f%%',12))
text(1.5,1.17,sprintf('Traf: %s',Loc))
text(1.5,1.15,sprintf('Mean of n = 500 maximums'))
text(1.5,1.13,sprintf('50k vehicles simulated'))
legend({'2.5 m IVD (20%)','5 m IVD (20%)','40%'},'Location','south','Orientation','horizontal')
legend('boxoff')
movegui(gcf,'north')


% FIGURE 3 -- EFFECT OF SPAN SIZE ON LOAD EFFECT
% figure        % Initialize figure
% % Set visibility for legend
% clear HV
% HV = repmat({'on'},1,4); HV{3} = 'off';
% 
% % For each platooning percentage
% for j = 1:size(PlatRate,2)
%     % For some of the intervehicle distances   
%     for n = 1:2
%         hold on
%         plot([1; PlatSizeNum'],[1; R(:,n,j)],'Color',Col{j},'LineStyle',Pat{n},'Marker','*','HandleVisibility',HV{(j-1)*2+n},'LineWidth',1);
%     end
% end
% title('Effect of Platoon Size on Load Effect')
% ylabel('Analysis / Base Analysis')
% ylim([0.95 1.25])
% xlabel('Platoon Size (#)')
% xlim([1 4])
% set(gca, 'XTick', 1:4)
% text(1.5,1.21,sprintf('IL: %s',ILname))
% text(1.5,1.19,sprintf('TrRate: %.1f%%',12))
% text(1.5,1.17,sprintf('Traf: %s',Loc))
% text(1.5,1.15,sprintf('Mean of n = 500 maximums'))
% text(1.5,1.13,sprintf('50k vehicles simulated'))
% legend({'2.5 m IVD (20%)','5 m IVD (20%)','40%'},'Location','south','Orientation','horizontal')
% legend('boxoff')
% movegui(gcf,'north')
