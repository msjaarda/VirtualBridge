function [NumLanes,Lane,LaneData,TrData,FolDist] = UpdateData(BaseData,LaneData,TrData,FolDist)
%Updates the data for the main variables, based on row-by-row input in BaseData
% Function is necessary because of Simple Input Method
% This function needs to probe the existance of variables, because it
% is possible they are not included, having been assigned through Complete
% Input, rather than Simple Input

% Get Lane Truck Distribution, Lane.TrDistr, and Lane Directions, Lane.Dir
if ismember('LaneTrDistr', BaseData.Properties.VariableNames)
    Lane.TrDistr =  cellfun(@str2num,split(BaseData.LaneTrDistr{:},','));
end
% Neither of these are optional, so we don't check their existance
Lane.Dir =  cellfun(@str2num,split(BaseData.LaneDir{:},','));
% Get NumLanes from the length of Lane.Dir
NumLanes = length(Lane.Dir);

% Start with FolDist and TrData, these are quite simple

% Update FolDist if necessary
if ismember('Flow', BaseData.Properties.VariableNames)
    % Load FlowLib if necessary
    if ~exist('FlowLib','var')
        load('FlowLib.mat')
    end
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
    % Load TrLib if necessary
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


% Next do LaneData... quite complicated for Simple/Complete agreement
% GetInfLines function is done next - we prepare LaneData for that function

% Start with transverse influence lines
% If TransILx is given then we need to solve for the Lane Factors, LaneFact
if ismember('TransILx', BaseData.Properties.VariableNames)
    % Check if it is not a cell (it is zero, no TransILs)
    if ~iscell(BaseData.TransILx)
        % LaneFact is 1 with no Transverse influence lines given
        LaneFact = 1;
    else
        % Use x and y coordinates to define line, then LaneCen to get LaneFact
        TransILx = cellfun(@str2num,split(BaseData.TransILx{:},','));
        TransILy = cellfun(@str2num,split(BaseData.TransILy{:},','));
        LaneCen = cellfun(@str2num,split(BaseData.LaneCen{:},','));
        LaneFact = interp1(TransILx,TransILy,LaneCen,'linear','extrap');
    end
    % We gain info on LaneData.Lane here 1:length(LaneFact)
else
    % LaneFact is 1 when no Transverse influence lines are given
    LaneFact = 1;
end

% NOTE: You can only mix ILs if they have the same ILRes...
% This is why we wanted to stick to 0.5 earlier. Right now only Tessin ILs
% have ILRes ~= 1

% Check if Simple Input method Influence lines are given
if ismember('ILs', BaseData.Properties.VariableNames)
    % Load InfLib if necessary
    if ~exist('InfLib','var')
        load('InfLib.mat')
    end
    % Must clear LaneData if it previously exists
    clear LaneData
    % Split input by the commas to get individual IL families
    ILs = split(BaseData.ILs{:},',');
    
    % BaseData.ILs = ILFamily.SpecificILName,OtherILFamily,OtherILFamily. ...

    % Here we create Infx and Infv just as they would be in LaneData from
    % Complete Input
    
    % A generic 'V', 'Mp', or 'Mn' means all ILs for that Library
    % A specific 'Mp20' or 'V80' can be selected with dot '.' demarcation
    % Example: V.V80 means just V80 from Library V
        
    % Initialize Table Columns
    [LaneData.InfNum, LaneData.Name, LaneData.Lane, LaneData.x, LaneData.Infv] = deal([]);
    
    % Populate LaneData.Infv and LaneData.x
    % Step through each IL family given -- ILs = IL
    for i = 1:length(ILs)
        % If necessary, split influence lines by '.' (just one IL from family)
        J = split(ILs{i},'.');
        % ILs should just be the overall IL family name (override if necessary)
        ILs{i} = J{1};
        % If a split occured (length(J) > 1), select just that Name index
        if length(J) > 1
            Index = find(strcmp(J(2),InfLib.(ILs{i}).Name));
        else
            % If no split occured, index is simply all ILs in family
            Index = 1:size(InfLib.(ILs{i}).Infv,2);
        end
    
        % Create nan matrix and populate (made to replicate Complete Input)
        [a, b] = size(InfLib.(ILs{i}).Infv(:,Index));
        [c, ~] = size(LaneData.Infv);
        z = nan(max(a,c),b);
        z(1:a,1:b) = InfLib.(ILs{i}).Infv(:,Index);
        if a > c && c > 0
            LaneData.Infv(c+1:a,:) = nan;
        end
        LaneData.Infv = [LaneData.Infv, z];
        % Replace Infx if it is longer than previous
        if length(InfLib.(ILs{i}).Infx) > length(LaneData.x)
            LaneData.x = InfLib.(ILs{i}).Infx;
        end
        % Add Names cummulatively
        LaneData.Name = [LaneData.Name, InfLib.(ILs{i}).Name(Index)];
    end
    [~, NumInf] = size(LaneData.Infv);
    
    % Get InfNum/Name/Lane
    % If LaneFactor is 1, there is no transverse consideration - simple
    if LaneFact == 1
        LaneData.Lane = zeros(NumInf,1);
        LaneData.InfNum = 1:NumInf; 
    else
        % With transverse consideration, each line must be scaled per lane
        LaneData.Infv = LaneData.Infv*LaneFact(1);
        LaneData.Lane = ones(NumInf,1);
        LaneData.Name = repmat(LaneData.Name,1,length(LaneFact));
        LaneData.InfNum = repmat(1:NumInf,1,length(LaneFact));
        for i = 2:length(LaneFact)
            LaneData.Infv = [LaneData.Infv, LaneData.Infv*LaneFact(i)];
            LaneData.Lane = [LaneData.Lane; i*ones(NumInf,1)];
        end
    end
    
    % Add nans and convert struct2table for adhearance to Complete Method
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

