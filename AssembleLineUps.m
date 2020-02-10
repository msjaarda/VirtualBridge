function  [TrLineUpMaster] = AssembleLineUps(AllLaneLineUp,BatchSize,NumLanes,LaneData,BaseData)
%AssembleLineUps Does a little virtual WIM compiling
AllLaneLineUp = AllLaneLineUp(~cellfun('isempty',AllLaneLineUp));
% Assemble lane specific data and sort by axle position
% SORTROW

% Experiment for case of no platoons and all lanes same dir
B = LaneData.Direction(LaneData.Direction < 100);

if BaseData.RunPlat == 0 && all(B == B(1))
    [s,~] = size(AllLaneLineUp);
    for i = 1:s
        %if ~isempty(AllLaneLineUp{i})
            AllLaneLineUp{i} = AllLaneLineUp{i}(AllLaneLineUp{i}(:,2)>0,:);
        %end
    end
end

if BaseData.VWIM == 1 || BaseData.Apercu == 1
    VehLineUp = cat(1,AllLaneLineUp{:});
    VehLineUp = sortrows(VehLineUp);
    
    tmp3 = zeros(size(AllLaneLineUp{1},1)+size(AllLaneLineUp{2},1),size(AllLaneLineUp{2},2));

    [~,tmp2] = sort([AllLaneLineUp{1}(:,1) ;  AllLaneLineUp{2}(:,1)]);
    % tmp2 = merge_sorted(AllLaneLineUp{1}(:,1) ,  AllLaneLineUp{2}(:,1));
    
    tmp3(tmp2<=size(AllLaneLineUp{1},1),:) = AllLaneLineUp{1};
    tmp3(tmp2>size(AllLaneLineUp{1},1),:) = AllLaneLineUp{2};
    
    
else
    %AA = cellfun(@(x) x(:,1:5),AllLaneLineUp,'UniformOutput',false);
    %VehLineUp = cat(1,AA{:});
    VehLineUp = cat(1,AllLaneLineUp{:});
    VehLineUp = sortrows(VehLineUp);
end



% Assign a sequential number to each vehicle (fifth col is veh starts only)
VehLineUp(VehLineUp(:,5) == 1,5) = 1:length(VehLineUp(VehLineUp(:,5) == 1,5));

% If we have platoons (couldn't estimate length perfectly, hence Suprlus variable) trim to length
% Should we be careful here if we didn't run certain lanes which had no
% vehs?
if BaseData.RunPlat == 1
    VehLineUp = VehLineUp(1:find(VehLineUp(:,5)==BatchSize),:);
end

% Swap vehicles going in opposite direction, then sort again
for i = 1:NumLanes
    if LaneData.Direction(i) ~= 1
        VehLineUp(VehLineUp(:,4) == i,1) = VehLineUp(end,1) + 5 - VehLineUp(VehLineUp(:,4) == i,1);
        VehLineUp = sortrows(VehLineUp);
    end
end


% For cases without platooning (hense no surplus... and cases with vehicles
% moving in the same direction, we could remove cars first to save time
% with "sortrows" (still expensive)

% Creation TruckLineUp by removing vehicles
TrLineUpMaster = VehLineUp(VehLineUp(:,2)>0,:);

end

