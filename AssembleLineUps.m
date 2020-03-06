function  [AxLineUp, VehLineUp] = AssembleLineUps(LaneAxLineUp,LaneVehLineUp,BatchSize,NumLanes,BaseData,LaneDir,FixVars)
%AssembleLineUps Merges LaneLineUps (Ax and Veh)
%LaneAx is for the bridge, LaneVeh is for the VWIM

% LaneAxLineUp has [LaneAxSpCu LaneAxLoads LaneAxVehNum LaneAxLaneNum LaneAxVehBeg]
%                       1           2           3             4           5

% Take only the non-empty cells of LaneAxLineUp
LaneAxLineUp = LaneAxLineUp(~cellfun('isempty',LaneAxLineUp));

% Assemble lane specific data
AxLineUp = cat(1,LaneAxLineUp{:});

% Swap vehicles going in opposite direction, then sort again
% for i = 1:NumLanes
%     if LaneDir(i) ~= 1
%         %AxLineUp(AxLineUp(:,4) == i,1) = AxLineUp(end,1) + 5 - AxLineUp(AxLineUp(:,4) == i,1);
%         % Also switch the LaneAxVehBeg
%         X = AxLineUp(AxLineUp(:,4) == i,:);
%         X(:,6) = X(end,1) + 5 - X(:,1);
%         X(:,7) = [diff(X(:,5)); 1];
%         X(X(:,7)<0,7) = 0;
%         
%         AxLineUp(AxLineUp(:,4) == i,1) = X(:,6);
%         AxLineUp(AxLineUp(:,4) == i,5) = X(:,7);
%         
%     end
% end

% Sort by axle position
AxLineUp = sortrows(AxLineUp);

% Assign a sequential number to each vehicle (replace fifth col...was VehBeg)
AxLineUp(AxLineUp(:,5) == 1,5) = 1:length(AxLineUp(AxLineUp(:,5) == 1,5));

% If we have platoons (couldn't estimate length perfectly, hence Suprlus variable) trim to length
if BaseData.RunPlat == 1
    if FixVars.CarWgt == 0
        AxLineUp = AxLineUp(1:find(AxLineUp(:,5) == BatchSize*BaseData.TrRate),:);
    else
        AxLineUp = AxLineUp(1:find(AxLineUp(:,5) == BatchSize),:);
    end
end





% Done creating AxLineUp... now create VehLineUp if necessary
if BaseData.VWIM == 1 || BaseData.Apercu == 1
  
    % Take only the non-empty cells of LaneVehLineUp
    LaneVehLineUp = LaneVehLineUp(~cellfun('isempty',LaneVehLineUp));
    
 
    
    % Assemble lane specific data
    VehLineUp = cat(1,LaneVehLineUp{:});
    
%     % Swap vehicles going in opposite direction, then sort again
%     for i = 1:NumLanes
%         if LaneDir(i) ~= 1
%             % Works as long as col4 stays as 'FS' or LaneNum
%             
%             X = VehLineUp(VehLineUp(:,4) == i,:);
%             
%             
%             VehLineUp(VehLineUp(:,4) == i,1) = VehLineUp(end,1) + 5 - VehLineUp(VehLineUp(:,4) == i,1);
%         end
%     end
    
    % Sort by axle position
    VehLineUp = sortrows(VehLineUp);
    
    % If we have platoons (couldn't estimate length perfectly, hence Suprlus variable) trim to length
    if BaseData.RunPlat == 1
        if FixVars.CarWgt == 0
            VehLineUp = VehLineUp(1:BatchSize*BaseData.TrRate,:);
        else
            VehLineUp = VehLineUp(1:BatchSize,:);
        end
    end

end

end

