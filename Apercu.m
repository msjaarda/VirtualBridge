function T = Apercu(PDC,Title,Infx,Infv,BrStInd,TrLineUp,PEsia,DLF)
% Plot A Series of WIM Vehicles on a Bridge

% Can this be done for a MatSim Results file?

% Get number of lanes
Lanes = unique(PDC.FS);

% Define Plot Colors
Col{1} = [.94 .28 .18]; Col{2} = [.12 .45 .82]; Col{3} = [.27 .83 .19];
Col{4} = [.94 .28 .18]; Col{5} = [.12 .45 .82]; Col{6} = [.27 .83 .19];

% Plot Influence Line
subplot(length(Lanes)+2,1,length(Lanes)+2)
plot(Infx,-Infv,'Color',[0 0 0],'LineWidth',1.5)
xlabel('Distance Along Bridge (m)'); ylabel('Inf Line')
text(1,-max(Infv)+max(Infv)/5,sprintf('%.0f%% of E_{SIA}',PEsia*100),'FontSize',11,'FontWeight','bold','Color','k')
set(gca,'ytick',[]); set(gca,'yticklabel',[])

% Overall plot title
sgtitle([Title ' Critical Case']);

% Define Q, an excerpt of TrLineUp with just those vehicles on the bridge
Q = TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd+length(Infv)-1,:);
% Define T, an excerpt of WIM/VWIM PDC with just vehicles on the bridge
T = PDC(unique(Q(:,3)),:);

% Add each lane in loop q is a subset of Q, vc is vehicle corners
for i = 1:length(Lanes)
    q{i} = Q(Q(:,4) == Lanes(i),:);
    t{i} = T(T.FS == Lanes(i),:);
    q{i}(:,1) = q{i}(:,1) - BrStInd;
    q{i}(:,5) = q{i}(:,5) - BrStInd;
    [a, b] = unique(q{i}(:,3));
    V = TrLineUp(TrLineUp(:,4) == i,5) - BrStInd;
    negflag = V(1) < 0;
    if length(b) > 0
        for j = 1:length(b)
            ac{i}(:,j) = accumarray(q{i}(q{i}(:,3) == a(j),1),q{i}(q{i}(:,3) == a(j),2),[length(Infx) 1]);
            if j == 1 & negflag
                vc{i}(j,1) = 0;
            else
                vc{i}(j,1) = q{i}(b(j),5)-1;%1 for 5
            end
            if j == length(b)
                vc{i}(j,2) = q{i}(end,5)+1;%1 for 5
            else
                vc{i}(j,2) = q{i}(b(j+1)-1,5)+1;%1 for 5
            end
        end
        barp(:,i) = sum(ac{i},2);
    else
        ac{i} = 0;
        vc{i} = 0;
    end
end

% Plot axle loads
subplot(length(Lanes)+2,1,length(Lanes)+1)
h = bar(barp/9.81,1.2,'grouped','EdgeColor','k');
xlim([0 max(Infx)])
ylim([0 ceil(max(max(barp/9.81))/5)*5])
ylabel('Axle Loads (t)')
% Could add total weight on the bridge and DLA
text(1,ceil(max(max(barp/9.81))/5)*5-3,sprintf('Total: %.0f kN (DLF = %.2f)',sum(sum(barp)),DLF),'FontSize',11,'FontWeight','bold','Color','k')

for i = 1:length(Lanes)
    h(i).FaceColor = Col{i};
end

for j = 1:length(Lanes)
    subplot(length(Lanes)+2,1,j)
    for i = 1:numel((vc{j}))/2
        hold on
        fill([vc{j}(i,1) vc{j}(i,1) vc{j}(i,2) vc{j}(i,2)],[2 8 8 2],Col{j},'EdgeColor','k','LineWidth',1.5);
        fill([vc{j}(i,2)-0.1 vc{j}(i,2)-0.1 vc{j}(i,2)+0.1 vc{j}(i,2)+0.1],[2.5 7.5 7.5 2.5],'k','EdgeColor','k','LineWidth',1.5);
        fill([vc{j}(i,1)-0.7 vc{j}(i,1)-0.7 vc{j}(i,1) vc{j}(i,1)],[3.75 6.25 7 3],'k','EdgeColor','k','LineWidth',1.5);
        text((vc{j}(i,1)+vc{j}(i,2))/2,5,sprintf('%i ax | %.1f t',t{j}.AX(i),t{j}.GW_TOT(i)/1000),'FontSize',11,'FontWeight','bold','HorizontalAlignment','center','Color',[.7 .7 .7])
        text((vc{j}(i,1)+vc{j}(i,2))/2,9,sprintf('%.0f kph',t{j}.SPEED(i)/100),'FontSize',11,'FontWeight','bold','HorizontalAlignment','center','Color','k')
    end
    hold on
    scatter(q{j}(:,5),7*ones(size(q{j},1),1),'filled','s','MarkerFaceColor','k')%1 for 5
    hold on
    scatter(q{j}(:,5),3*ones(size(q{j},1),1),'filled','s','MarkerFaceColor','k')%1 for 5
    xlim([0 max(Infx)])
    ylim([0 10])
    ylabel(['Lane ' num2str(Lanes(j))]); set(gca,'ytick',[]); set(gca,'yticklabel',[]) 
end
set(gcf,'Position',[100 100 900 750])
