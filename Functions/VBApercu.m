function T = VBApercu(PDC,Title,ILData,p,BrStInd,TrLineUp,PEsia,DLF,LaneDir,ILRes)
% Plot a Series of WIM or VWIM Vehicles on a Bridge

% Take only the influence lines that apply to the current InfCase
Infv = ILData.v{p};
Infx = 0:ILRes:(length(ILData.v{p})-1)*ILRes;
    
figure

% Just for displaying class, see Classify
TrTyps = [0; 11; 119; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238; 41; 42; 43; 44; 45; 46];
TrNames = ["NC" "11" "11bis" "12" "22" "23" "111" "1111r" "112r" "1211r" "122" "11112r" "112a" "113a" "123a" "5ax 60t" "6ax 60t" "7ax 72t" "8ax 84t" "9ax 96t" "8ax 96t"];

% Get number and name of lanes
Lanes = unique(PDC.LANE); NumLanes = length(Lanes);
NumLanePlots = length(LaneDir);

% Define Plot Colors
Col{1} = [.94 .28 .18]; Col{2} = [0 .447 .74]; Col{3} = [.27 .83 .19];       % Yellow and Blue
Col{4} = [.99 .67 0]; Col{5} = Col{2}; Col{6} = Col{3}; % Col 4 is Red

% Plot Influence Line
% Open up subplot and choose the last subplot
sp(NumLanePlots+2) = subplot(NumLanePlots+2,1,NumLanePlots+2);
% Note that trucks go the other way that is plotted... must flip ILs
if size(Infv,2) == 1 | all(all(Infv == Infv(:,1),2))
    plot(Infx,flip(-Infv),'k','LineWidth',1.5)
else
    for i = 1:size(Infv,2)
        hold on
        plot(Infx,flip(-Infv(:,i)),'Color',Col{i},'LineWidth',1.5)
    end
end
xlabel('Distance Along Bridge (m)'); ylabel('Inf Line'); xlim([-0.5 max(Infx)+0.5]); box on
text(1,-max(max(Infv))+max(max(Infv))/5,sprintf('%.1f%% of E_{SIA}',PEsia*100),'FontSize',11,'FontWeight','bold','Color','k')
PerI = find(ILData.Name{p} == '.');
text(max(Infx)-1,-max(max(Infv))+max(max(Infv))/5,sprintf('%s',ILData.Name{p}(PerI(1)+1:PerI(end)-1)),'FontSize',11,'FontWeight','bold','Color','k','HorizontalAlignment','right')
set(gca,'ytick',[]); set(gca,'yticklabel',[])

% Define overall plot title
sgtitle(Title);

% Col1 of TrLineUp is Rounded w/ ILRes, Col5 is actual distance

% How does Q work?! BrStInd no errors??
% Q is like AllTrAx and T is like AllVehAx I think

% Define Q, an excerpt of TrLineUp with just those vehicles on the bridge
Q = TrLineUp(TrLineUp(:,1) >= BrStInd & TrLineUp(:,1) <= BrStInd+length(Infx)-1,:); % added equals...
% Define T, an excerpt of WIM/VWIM PDC with just vehicles on the bridge
T = PDC(unique(Q(:,3)),:);

% Gather variables for the plots of each lane
for i = 1:NumLanes
    % q is a subset of Q, t is a subset of T
    q{i} = Q(Q(:,4) == Lanes(i),:); t{i} = T(T.LANE == Lanes(i),:);
    % normalize q values for start of the bridge at zero
    q{i}(:,1) = round((q{i}(:,1) - BrStInd)); q{i}(:,5) = q{i}(:,5) - BrStInd*ILRes;
    [a, b] = unique(q{i}(:,3));
    % vc stands for vehicle corners, ac for accumulated
    if ~isempty(b)
        for j = 1:length(b)
            locations = q{i}(q{i}(:,3) == a(j),1);
            axlevalues = q{i}(q{i}(:,3) == a(j),2);

            % Assign initial if necessary
            if sum(locations == 0) > 0
                initial(i,j) = axlevalues(locations == 0);
            else
                initial(i,j) = 0;
            end
            % Assign ac if necessary
            if sum(locations) > 0
                ac{i}(:,j) = accumarray(locations(locations ~= 0),axlevalues(locations ~= 0),[Infx(end)/ILRes 1]);
            else
                ac{i}(:,j) = zeros([Infx(end)/ILRes 1]);
            end
            
            Temp = TrLineUp(TrLineUp(:,3) == a(j),5);
            if LaneDir(i) == 1
                vc{i}(j,1) = Temp(1)-ILRes*BrStInd-1;
                vc{i}(j,2) = Temp(end)-ILRes*BrStInd+1;
            else
                vc{i}(j,2) = Temp(1)-ILRes*BrStInd+1;
                vc{i}(j,1) = Temp(end)-ILRes*BrStInd-1;
            end
        end
        barp(:,i) = [sum(initial(i,:),2); sum(ac{i},2)];
        NoVeh(i) = 0;
    else
        ac{i} = 0; vc{i} = 0;
        NoVeh(i) = 1;
    end
end

if size(barp,2) < NumLanePlots
    barp(1:size(barp,1), size(barp,2)+1:NumLanePlots) = 0.001;
end

% Plot axle loads
sp(NumLanePlots+1) = subplot(NumLanePlots+2,1,NumLanePlots+1);
h = bar(0:ILRes:Infx(end),barp/9.81,1.2/ILRes,'grouped','EdgeColor','k');
xlim([-0.5 max(Infx)+0.5]);
ylim([0 ceil(max(max(barp/9.81))/5)*5])
ylabel('Axle Loads (t)')
set(gca,'xticklabel',[])

% Show text of DLA and Total Weight
text(1,ceil(max(max(barp/9.81))/5)*5-3,sprintf('Total: %.0f (DLF = %.2f)',sum(sum(barp)),DLF),'FontSize',11,'FontWeight','bold','Color','k')

if ILRes ~= 1
    xtemp = 0:ILRes:Infx(end);
    Infvtemp = interp1(Infx,Infv,xtemp);
    if size(Infvtemp,1) == 1
        Infvtemp = Infvtemp';
    end
else
    Infvtemp = Infv;
end

text(max(Infx)-1,ceil(max(max(barp/9.81))/5)*5-3,sprintf('Load Effect: %.0f',DLF*sum(sum(barp(1:end,:).*flip(Infvtemp(:,1:end))))),'FontSize',11,'FontWeight','bold','Color','k','HorizontalAlignment','right')

for i = 1:NumLanes
    if NoVeh(i) ~= i
        h(i).FaceColor = Col{i};
    end
end

count = 0;
for j = 1:NumLanePlots
    sp(j) = subplot(NumLanePlots+2,1,j);
    if j == 1 && any(ismember(T.Properties.VariableNames,'DTS'))
        text(0,9,datestr(T.DTS(1),'mmm-dd-yyyy'),'FontSize',9,'FontWeight','bold','HorizontalAlignment','left','Color','k','Color',[0.5 0.5 0.5])
        text(0,1.25,datestr(T.DTS(1),'HH:MM:SS'),'FontSize',9,'FontWeight','bold','HorizontalAlignment','left','Color','k','Color',[0.5 0.5 0.5])
    end
    if j <= length(Lanes)
        for i = 1:numel((vc{j}))/2
            hold on
            Fillcolor = 'k';
            % Truck Outline
            fill([vc{j}(i,1) vc{j}(i,1) vc{j}(i,2) vc{j}(i,2)],[2 8 8 2],Col{j},'EdgeColor',Fillcolor,'LineWidth',1.5);
            if LaneDir(j) == 1
                % Back Bumper
                fill([vc{j}(i,2)-0.1 vc{j}(i,2)-0.1 vc{j}(i,2)+0.1 vc{j}(i,2)+0.1],[2.5 7.5 7.5 2.5],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
                % Front of Truck
                fill([vc{j}(i,1)-0.7 vc{j}(i,1)-0.7 vc{j}(i,1) vc{j}(i,1)],[3.75 6.25 7 3],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
                % Mirrors
                fill([vc{j}(i,1)+1.1 vc{j}(i,1)+1.3 vc{j}(i,1)+1.5 vc{j}(i,1)+1.3],[2 1.5 1.5 2],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
                fill([vc{j}(i,1)+1.1 vc{j}(i,1)+1.3 vc{j}(i,1)+1.5 vc{j}(i,1)+1.3],[8 8.5 8.5 8],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
            else
                % Back Bumper
                fill([vc{j}(i,1)-0.1 vc{j}(i,1)-0.1 vc{j}(i,1)+0.1 vc{j}(i,1)+0.1],[2.5 7.5 7.5 2.5],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
                % Front of Truck
                fill([vc{j}(i,2)+0.7 vc{j}(i,2)+0.7 vc{j}(i,2) vc{j}(i,2)],[3.75 6.25 7 3],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
                % Mirrors
                fill([vc{j}(i,2)-1.1 vc{j}(i,2)-1.3 vc{j}(i,2)-1.5 vc{j}(i,2)-1.3],[2 1.5 1.5 2],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
                fill([vc{j}(i,2)-1.1 vc{j}(i,2)-1.3 vc{j}(i,2)-1.5 vc{j}(i,2)-1.3],[8 8.5 8.5 8],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
            end
            % Only write text if it is within the plot...
            if (vc{j}(i,1)+vc{j}(i,2))/2 > max(Infx)/15 && (vc{j}(i,1)+vc{j}(i,2))/2 < max(Infx)-max(Infx)/15
                text((vc{j}(i,1)+vc{j}(i,2))/2,5,sprintf('%i ax | %.1f t',t{j}.AX(i),t{j}.GW_TOT(i)/1000),'FontSize',11,'FontWeight','bold','HorizontalAlignment','center','Color','k')
            end
            if (vc{j}(i,1)+vc{j}(i,2))/2 > max(Infx)/15 && (vc{j}(i,1)+vc{j}(i,2))/2 < max(Infx)-max(Infx)/15 && ismember('SPEED', T.Properties.VariableNames)
                text((vc{j}(i,1)+vc{j}(i,2))/2,9,sprintf('%.0f kph',t{j}.SPEED(i)/100),'FontSize',11,'FontWeight','bold','HorizontalAlignment','center','Color','w')
            end
            if (vc{j}(i,1)+vc{j}(i,2))/2 > max(Infx)/15 && (vc{j}(i,1)+vc{j}(i,2))/2 < max(Infx)-max(Infx)/15
                text((vc{j}(i,1)+vc{j}(i,2))/2,1.25,sprintf('CLASS %s',TrNames(TrTyps == t{j}.CLASS(i))),'FontSize',9,'FontWeight','bold','HorizontalAlignment','center','Color','w')
            end
        end
        % Add wheel locations (column 5 has actual wheel locations, column 1 would be approximate)
        hold on
        scatter(q{j}(:,5),7*ones(size(q{j},1),1),'filled','s','MarkerFaceColor','k')
        hold on
        scatter(q{j}(:,5),3*ones(size(q{j},1),1),'filled','s','MarkerFaceColor','k')
        xlim([-0.5 max(Infx)+0.5]); ylim([0 10])
        ylabel(['Lane ' num2str(Lanes(j))]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
        yaxish = gca; yaxish.YRuler.Axle.Visible = 'off';
        if j ~= NumLanePlots
            set(gca,'xticklabel',[],'xcolor','none','xtick',[])
            yline(0,'--w','LineWidth',7)
        end
    else
        xlim([-0.5 max(Infx)+0.5]); ylim([0 10])
        ylabel(['Lane ' num2str(Lanes(j-1)+1)]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
        yaxish = gca; yaxish.YRuler.Axle.Visible = 'off';
        if j ~= NumLanePlots
            set(gca,'xticklabel',[],'xtick',[])
            yline(0,'--w','LineWidth',7)
        end
    end
    set(gca,'Color',[.6 .6 .6])
end

set(gcf,'Position',[100 100 900 750])

% Left Bottom Width Height
Left = sp(1).Position(1);
Width = sp(1).Position(3);
GapSize = (sp(end-1).Position(2) - sp(end).Position(4) - sp(end).Position(2))/2;
NewHeight = sp(1).Position(4) + GapSize;
NewHeightIn = sp(1).Position(4) + GapSize + GapSize;

% Remove gap between InfLine and Axle Loads
set(sp(end), 'Position',   [Left   sp(end).Position(2)                     Width    NewHeight]);
set(sp(end-1), 'Position', [Left   sp(end-1).Position(2) - GapSize         Width    NewHeight]);

% Remove gap between lanes
for i = 1:NumLanePlots
    if i == 1
        set(sp(i), 'Position',   [Left   sp(i).Position(2) - GapSize       Width    NewHeight]);
    elseif i == NumLanePlots
        set(sp(i), 'Position',   [Left   sp(i).Position(2)                 Width    NewHeight]);
    else
        set(sp(i), 'Position',   [Left   sp(i).Position(2) - GapSize       Width    NewHeightIn]);
    end
end

end
    


