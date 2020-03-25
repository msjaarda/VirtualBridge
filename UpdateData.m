function [NumLanes,Lane,LaneData,TrData,FolDist] = UpdateData(BaseData,LaneData,TrData,FolDist)
%UPDATEDATA UpdateData, based on row-by-row input in BaseData

% Get Lane Truck Distribution, Lane.TrDistr, and Lane Directions, Lane.Dir
if ismember('LaneTrDistr', BaseData.Properties.VariableNames)
    Lane.TrDistr =  cellfun(@str2num,split(BaseData.LaneTrDistr{:},','));
end
if ismember('LaneDir', BaseData.Properties.VariableNames)
    Lane.Dir =  cellfun(@str2num,split(BaseData.LaneDir{:},','));
    % Get NumLanes
    NumLanes = length(Lane.Dir);
end

% Update FolDist if necessary
if ismember('Flow', BaseData.Properties.VariableNames)
    % Get FolDist (as long as Flow it isn't zero)  
    % Load FlowLib
    load('FlowLib.mat')
    % Ensure that the chosen flow condition exists in FlowLib
    if isfield(FlowLib,BaseData.Flow{:})
        % Overwrite
        FolDist = FlowLib.(BaseData.Flow{:});
    end
else
    % Print warning if no input
    if isempty(FolDist)
        fprintf('\nWarning: No FolDist input\n\n')
    end
end

% Update TrData if necessary
if ismember('Traffic', BaseData.Properties.VariableNames)
    % Get TrData (as long as traffic it isn't zero)  
    % Load TrLib
    % Why do we first check if it exists? To figure out
    if ~exist('TrLib','var')
        load('TrLib.mat')
    end
    % Ensure that the chosen traffic exists in TrLib
    if isfield(TrLib,BaseData.Traffic{:})
        % Overwrite
        TrData = TrLib.(BaseData.Traffic{:});
    end
else
    % Print warning if no input
    if isempty(TrData)
        fprintf('\nWarning: No TrData input\n\n')
    end
end


% Lane Input is by far the most difficult here...

if ismember('TransILx', BaseData.Properties.VariableNames)
    % Gotta solve this..
    if ~iscell(BaseData.TransILx)
        LaneFact = 1;
    else
        TransILx = cellfun(@str2num,split(BaseData.TransILx{:},','));
        TransILy = cellfun(@str2num,split(BaseData.TransILy{:},','));
        LaneCen = cellfun(@str2num,split(BaseData.LaneCen{:},','));
        LaneFact = interp1(TransILx,TransILy,LaneCen,'linear','extrap');
    end
    % We gain info on LaneData.Lane here 1:length(LaneFact)
else
    LaneFact = 1;
    % We gain info on LaneData.Lane here 0
end

if ismember('ILs', BaseData.Properties.VariableNames)
    ILs = split(BaseData.ILs{:},',');
    if ~exist('InfLib','var')
        load('InfLib.mat')
    end
    
    % Here we create Infx and Infv just as they would be in LaneData form
    
    % A generic 'V', 'Mp', or 'Mn' means all ILs for that Library
    % A specific 'Mp20' or 'V80' means just that one
    
    % Make sure all ILs use 0.5 step for now
    
    LaneData.InfNum = [];
    LaneData.Name = [];
    LaneData.Lane = [];
    LaneData.x = [];
    LaneData.Infv = [];
    
    % Start with Infv and x
    for i = 1:length(ILs)
        [a, b] = size(InfLib.(ILs{i}).Infv);
        [c, ~] = size(LaneData.Infv);
        z = nan(max(a,c),b);
        z(1:a,1:b) = InfLib.(ILs{i}).Infv;
        if a > c && c > 0
            LaneData.Infv(c+1:a,:) = nan;
        end
        LaneData.Infv = [LaneData.Infv, z];
        if length(InfLib.(ILs{i}).Infx) > length(LaneData.x)
            LaneData.x = InfLib.(ILs{i}).Infx;
        end
        LaneData.Name = [LaneData.Name, InfLib.(ILs{i}).Name];
    end
    [~, NumInf] = size(LaneData.Infv);
    
    % Get InfNum/Name/Lane
    if LaneFact == 1
        LaneData.Lane = zeros(NumInf,1);
        LaneData.InfNum = 1:NumInf; 
    else
        LaneData.Infv = LaneData.Infv*LaneFact(1);
        LaneData.Lane = ones(NumInf,1);
        LaneData.Name = repmat(LaneData.Name,1,length(LaneFact));
        LaneData.InfNum = repmat(1:NumInf,1,length(LaneFact));
        for i = 2:length(LaneFact)
            LaneData.Infv = [LaneData.Infv, LaneData.Infv*LaneFact(i)];
            LaneData.Lane = [LaneData.Lane; i*ones(NumInf,1)];
        end
    end
end

if ismember('ILs', BaseData.Properties.VariableNames)
    % Add nans and convert struct2table
    LaneData.Lane(length(LaneData.Lane)+1:a) = nan;
    LaneData.InfNum(length(LaneData.InfNum)+1:a) = nan;
    for i = length(LaneData.Name)+1:a
        LaneData.Name{i} = '';
    end
    
    if size(LaneData.Name,2)>size(LaneData.Name,1)
        LaneData.Name = LaneData.Name';
    end
    if size(LaneData.InfNum,2)>size(LaneData.InfNum,1)
        LaneData.InfNum = LaneData.InfNum';
    end
    if size(LaneData.Lane,2)>size(LaneData.Lane,1)
        LaneData.Lane = LaneData.Lane';
    end
    
    Y = array2table(LaneData.Infv);
    LaneData = rmfield(LaneData,'Infv');
    LaneData = struct2table(LaneData);
    LaneData = [LaneData Y];
    
    % Now we have to sort InfName, Name, and Lane
    [LaneData.InfNum, B] = sort(LaneData.InfNum);
    LaneData.Name = LaneData.Name(B);
    LaneData.Lane = LaneData.Lane(B);
    
    % Take the new sorted order and rearrange Var1:end
    Z = B(LaneData.InfNum > 0);
    LaneData(:,[5:end]) = LaneData(:,[Z+5-1]);
    
    LaneData.InfNum(LaneData.InfNum>0) = 1:length(LaneData.InfNum(LaneData.InfNum>0));
end

end

