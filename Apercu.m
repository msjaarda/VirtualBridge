function T = Apercu(PDC,Title,Infx,Infv,BrStInd,TrLineUp,PEsia,DLF)
% Plot A Series of WIM or VWIM Vehicles on a Bridge

% Fix for vehicles travelling in another direction

figure

% Get number and name of lanes
Lanes = unique(PDC.FS); NumLanes = length(Lanes);

% Define Plot Colors
%Col{1} = [.94 .28 .18]; Col{2} = [.12 .45 .82]; Col{3} = [.27 .83 .19];   % Red and Blue
Col{1} = [.99 .67 0]; Col{2} = [0 .447 .74]; Col{3} = [.27 .83 .19];       % Yellow and Blue
Col{4} = Col{1}; Col{5} = Col{2}; Col{6} = Col{3};

% Plot Influence Line
% Open up subplot and choose the last subplot
subplot(NumLanes+2,1,NumLanes+2)
% Note that trucks go the other way that is plotted... must flip IL
plot(Infx,flip(-Infv),'k','LineWidth',1.5)
xlabel('Distance Along Bridge (m)'); ylabel('Inf Line')
text(1,-max(Infv)+max(Infv)/5,sprintf('%.1f%% of E_{SIA}',PEsia*100),'FontSize',11,'FontWeight','bold','Color','k')
set(gca,'ytick',[]); set(gca,'yticklabel',[])

% Define overall plot title
sgtitle(Title);

% Define Q, an excerpt of TrLineUp with just those vehicles on the bridge
Q = TrLineUp(TrLineUp(:,1) >= BrStInd & TrLineUp(:,1) <= BrStInd+length(Infv)-1,:); % added equals...
% Define T, an excerpt of WIM/VWIM PDC with just vehicles on the bridge
T = PDC(unique(Q(:,3)),:);

% For adding platooning effects, add a column for in a platoon or not
Map = unique(Q(:,3));
if any(strcmp('AllVehPlat',T.Properties.VariableNames))
    for i = 1:length(Map)
        Q(Q(:,3) == Map(i),6) = T.AllVehPlat(i);
    end
end

% 4) what if we are at location 0, and no bar plot goes up

% Gather variables for the plots of each lane
for i = 1:NumLanes
    % q is a subset of Q, t is a subset of T
    q{i} = Q(Q(:,4) == Lanes(i),:); t{i} = T(T.FS == Lanes(i),:);
    % normalize q values for start of the bridge at zero
    q{i}(:,1) = q{i}(:,1) - BrStInd; q{i}(:,5) = q{i}(:,5) - BrStInd;
    [a, b] = unique(q{i}(:,3));
    % vc stands for vehicle corners, ac for accumulated
    if ~isempty(b)
        for j = 1:length(b)
            locations = q{i}(q{i}(:,3) == a(j),1);
            axlevalues = q{i}(q{i}(:,3) == a(j),2);
            % Assign initial if necessary, assign ac if necessary
            if locations(1) == 0
                initial(i,j) = axlevalues(1);
            else
                initial(i,j) = 0;
            end
            
            if sum(locations) > 0
                if locations(1) == 0
                    ac{i}(:,j) = accumarray(locations(2:end),axlevalues(2:end),[length(Infx)-1 1]);
                else
                    ac{i}(:,j) = accumarray(locations(1:end),axlevalues(1:end),[length(Infx)-1 1]);
                end
            else
                ac{i}(:,j) = zeros([length(Infx)-1 1]);
            end
            
            %ac{i}(:,j) = accumarray(q{i}(q{i}(:,3) == a(j),1),q{i}(q{i}(:,3) == a(j),2),[length(Infx) 1]);
            Temp = TrLineUp(TrLineUp(:,3) == a(j),5);
            vc{i}(j,1) = Temp(1)-BrStInd-1;
            vc{i}(j,2) = Temp(end)-BrStInd+1;
        end
        barp(:,i) = [sum(initial(i,:),2); sum(ac{i},2)];
        NoVeh(i) = 0;
    else
        ac{i} = 0; vc{i} = 0;
        NoVeh(i) = 1;
    end
end

% Plot axle loads
subplot(length(Lanes)+2,1,length(Lanes)+1)
h = bar(0:length(Infx)-1,barp/9.81,1.2,'grouped','EdgeColor','k');
% fixing the xlim doesn't allow visibility of maximums
%xlim([0 max(Infx)])
ylim([0 ceil(max(max(barp/9.81))/5)*5])
ylabel('Axle Loads (t)')
% Could add total weight on the bridge and DLA
% SHEAR CALCS ARE WRONG BECAUSE WE DON"T KNOW WHAT IS AT position ZERO FIX!
text(1,ceil(max(max(barp/9.81))/5)*5-3,sprintf('Total: %.0f (DLF = %.2f)',sum(sum(barp)),DLF),'FontSize',11,'FontWeight','bold','Color','k')
text(max(Infx)-1,ceil(max(max(barp/9.81))/5)*5-3,sprintf('Load Effect: %.0f',DLF*sum(sum(barp(1:end,:).*flip(Infv(1:end))))),'FontSize',11,'FontWeight','bold','Color','k','HorizontalAlignment','right')

for i = 1:NumLanes
    if NoVeh(i) ~= i
        h(i).FaceColor = Col{i};
    end
end

% More support for platooning graphics
if any(strcmp('AllVehPlat',T.Properties.VariableNames))
    [~, G] = unique(q{1}(:,3));
end

count = 0;
for j = 1:NumLanes
    subplot(length(Lanes)+2,1,j)
    for i = 1:numel((vc{j}))/2
        hold on
        if any(strcmp('AllVehPlat',T.Properties.VariableNames)) && q{j}(G(i),6)
            Fillcolor = [0.7 0 0];
            count = count + 1;
            else
            Fillcolor = [0.6 0.6 0.6];
            count = 0;
        end
        % Truck Outline
        fill([vc{j}(i,1) vc{j}(i,1) vc{j}(i,2) vc{j}(i,2)],[2 8 8 2],Col{j},'EdgeColor',Fillcolor,'LineWidth',1.5);
        % Back Bumper
        fill([vc{j}(i,2)-0.1 vc{j}(i,2)-0.1 vc{j}(i,2)+0.1 vc{j}(i,2)+0.1],[2.5 7.5 7.5 2.5],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
        % Front of Truck
        fill([vc{j}(i,1)-0.7 vc{j}(i,1)-0.7 vc{j}(i,1) vc{j}(i,1)],[3.75 6.25 7 3],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
        % Mirrors
        fill([vc{j}(i,1)+1.1 vc{j}(i,1)+1.3 vc{j}(i,1)+1.5 vc{j}(i,1)+1.3],[2 1.5 1.5 2],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
        fill([vc{j}(i,1)+1.1 vc{j}(i,1)+1.3 vc{j}(i,1)+1.5 vc{j}(i,1)+1.3],[8 8.5 8.5 8],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
        if count > 1
            fill([vc{j}(i,1)-1.5 vc{j}(i,1)-1.5 vc{j}(i,1)-1.5 vc{j}(i,1)-1.5],[3.2 6.8 6.8 3.2],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
            fill([vc{j}(i,1)-1.8 vc{j}(i,1)-1.8 vc{j}(i,1)-1.8 vc{j}(i,1)-1.8],[3.5 6.5 6.5 3.5],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
            fill([vc{j}(i,1)-2.1 vc{j}(i,1)-2.1 vc{j}(i,1)-2.1 vc{j}(i,1)-2.1],[3.8 6.2 6.2 3.8],'w','EdgeColor',Fillcolor,'LineWidth',1.5);
        end
        % Only write text if it is within the plot...
        if (vc{j}(i,1)+vc{j}(i,2))/2 > max(Infx)/15 && (vc{j}(i,1)+vc{j}(i,2))/2 < max(Infx)-max(Infx)/15
            text((vc{j}(i,1)+vc{j}(i,2))/2,5,sprintf('%i ax | %.1f t',t{j}.AX(i),t{j}.GW_TOT(i)/1000),'FontSize',11,'FontWeight','bold','HorizontalAlignment','center','Color','k')
        end
        if (vc{j}(i,1)+vc{j}(i,2))/2 > max(Infx)/15 && (vc{j}(i,1)+vc{j}(i,2))/2 < max(Infx)-max(Infx)/15
            text((vc{j}(i,1)+vc{j}(i,2))/2,9,sprintf('%.0f kph',t{j}.SPEED(i)/100),'FontSize',11,'FontWeight','bold','HorizontalAlignment','center','Color','k')
        end
    end
    % Add wheel locations (column 5 has actual wheel locations, column 1 would be approximate)
    hold on
    scatter(q{j}(:,5),7*ones(size(q{j},1),1),'filled','s','MarkerFaceColor','k')
    hold on
    scatter(q{j}(:,5),3*ones(size(q{j},1),1),'filled','s','MarkerFaceColor','k')
    xlim([0 max(Infx)]); ylim([0 10])
    ylabel(['Lane ' num2str(Lanes(j))]); set(gca,'ytick',[]); set(gca,'yticklabel',[]) 
end
set(gcf,'Position',[100 100 900 750])

