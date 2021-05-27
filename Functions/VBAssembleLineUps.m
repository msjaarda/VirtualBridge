function  [AxLineUp, VehLineUp] = VBAssembleLineUps(LaneAxLineUp,LaneVehLineUp,BatchSize,NumLanes,BaseData,LaneDir,FixVars)
%AssembleLineUps Merges LaneLineUps (Ax and Veh)
%LaneAx is for the bridge, LaneVeh is for the VWIM

% LaneAxLineUp [LaneAxSpCu LaneAxLoads LaneAxVehNum LaneAxLaneNum LaneAxVehBeg]
%                    1           2           3             4           5

% Take only the non-empty cells of LaneAxLineUp
LaneAxLineUp = LaneAxLineUp(~cellfun('isempty',LaneAxLineUp));

% Assemble lane specific data
AxLineUp = cat(1,LaneAxLineUp{:});

% Sort by axle position
AxLineUp = sortrows(AxLineUp);

% Assign a sequential number to each vehicle (replace fifth col...was VehBeg)
AxLineUp(AxLineUp(:,5) == 1,5) = 1:length(AxLineUp(AxLineUp(:,5) == 1,5));

% Initialize VehLineUp in case we don't populate
VehLineUp = [];

% Done creating AxLineUp... now create VehLineUp if necessary
if BaseData.VWIM == 1 || BaseData.Apercu == 1
  
    % Take only the non-empty cells of LaneVehLineUp
    LaneVehLineUp = LaneVehLineUp(~cellfun('isempty',LaneVehLineUp));

    % Assemble lane specific data
    VehLineUp = cat(1,LaneVehLineUp{:});
    
    % Sort by axle position
    VehLineUp = sortrows(VehLineUp);

end

end

