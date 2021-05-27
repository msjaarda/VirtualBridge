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


% FolDist is getting a make-over! We can now use qualitative measures:
% "Jammed" or "Stopped" : 0 kph
% "At-rest" or "Crawling" : 2 kph
% "Congested" : 30 kph
% "Free-flowing" : 1000 veh/hr

% Alternatively, one can simply use a single number representing speed in kph (for
% 100 and under), OR volume in veh/hr (any value over 100 is assume as volume)

% Update FolDist if necessary
if ismember('Flow', BaseData.Properties.VariableNames)
    % Overwrite
    FolDist = array2table(zeros(4,4));
    FolDist.Properties.VariableNames = {'TT', 'TC', 'CT', 'CC'};
    if iscell(BaseData.Flow)
       % VehSpd = str2num(BaseData.Flow{:});
       % if isempty(VehSpd)
            if strcmp(BaseData.Flow{:},'Jammed') || strcmp(BaseData.Flow{:},'Stopped')
                FolDist.TT = [0.1 15 2.93 10.8]';
                % Changed 20.04.21 after error caught by LM.
                % To be overhauled in next version.
                FolDist.TC = [0.1 15 2.15 10.9]';
                FolDist.CT = [0.1 15 2.41 9.18]';
%                 FolDist.TC = [0.1 15 2.41 9.18]';
%                 FolDist.CT = [0.1 15 2.15 10.9]';
% TC is a truck, followed by a car (<<<Truck<<Car)
%%%                         THIS IS WRONG!!! SEE BELOW... TC means
%%%                         <<<CAR<<<<TRUCK (Truck after car)
                FolDist.CC = [0.1 15 2.15 15.5]';
                VehSpd = 0; % kph
            elseif strcmp(BaseData.Flow{:},'At-rest') || strcmp(BaseData.Flow{:},'Crawling')
                VehSpd = 2; % kph
            elseif strcmp(BaseData.Flow{:},'Congested')
                VehSpd = 30; % kph
            elseif strcmp(BaseData.Flow{:},'Free-flowing')
                VehSpd = 1000; % > 100 therefore, veh/hr
            else
                fprintf('\nWarning: Not a recognized FolDist input\n\n')
            end
      %  end
    else
        VehSpd = BaseData.Flow;
    end
    if VehSpd > 0 && VehSpd < 101
        FolDist.TT = [VehSpd/15 15+1.1*VehSpd 2.15 9]';
        FolDist.TC = FolDist.TT;
        FolDist.CT = FolDist.TT;
        FolDist.CC = FolDist.TT;
    elseif VehSpd > 100
        % Difficult task... what to do with flowing traffic. Has a large
        % effect inside PerLaneRates AND GetFloDist... we opt to represent
        % exponential distribution AS beta! See Free-movingFollowing.xlsx
        beta = VehSpd*0.0126-0.2490; alpha = 1; 
        mind = 5.5; maxd = 1000; % m
        FolDist.TT = [mind maxd alpha beta]';
        FolDist.TC = FolDist.TT;
        FolDist.CT = FolDist.TT;
        FolDist.CC = FolDist.TT;
    elseif VehSpd == 0
        FolDist.TT = [0.1 15 2.93 10.8]';
        FolDist.TC = [0.1 15 2.15 10.9]';
        FolDist.CT = [0.1 15 2.41 9.18]';
        %                 FolDist.TC = [0.1 15 2.41 9.18]';
        %                 FolDist.CT = [0.1 15 2.15 10.9]';
        FolDist.CC = [0.1 15 2.15 15.5]';
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
    if iscell(BaseData.TransILx)
        % LaneFact is 1 with no Transverse influence lines given
        if BaseData.TransILx{:} == '0'
            if BaseData.InfSurf == 1
                LaneFact = 2;
            else
                LaneFact = 1;
            end
        else
            % Use x and y coordinates to define line, then LaneCen to get LaneFact
            TransILx = cellfun(@str2num,split(BaseData.TransILx{:},','));
            TransILy = cellfun(@str2num,split(BaseData.TransILy{:},','));
            LaneCen = cellfun(@str2num,split(BaseData.LaneCen{:},','));
            LaneFact = interp1(TransILx,TransILy,LaneCen,'linear','extrap');
        end
    elseif BaseData.InfSurf == 1
        LaneFact = 2;
    else
        LaneFact = 1;
    end
    % We gain info on LaneData.Lane here 1:length(LaneFact)
elseif BaseData.InfSurf == 1
    
    LaneFact = 2;
    
else
    % LaneFact is 1 when no Transverse influence lines are given
    LaneFact = 1;
end

% NOTE: You can only mix ILs if they have the same ILRes...
% This is why we wanted to stick to 0.5 earlier. Right now only Tessin ILs
% have ILRes ~= 1... now Pont Dalles also have ILRes ~= 1

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
    
    if BaseData.InfSurf == 1
        LaneData.Infv2 = [];
    end
    
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
        % added for Pont Dalles
        if LaneFact == 2
            z2 = z;
            % added for Pont Dalles
            z2(1:a,1:b) = InfLib.(ILs{i}).Infv2(:,Index);
        end
        if a > c && c > 0
            LaneData.Infv(c+1:a,:) = nan;
            if LaneFact == 2
                LaneData.Infv2(c+1:a,:) = nan;
            end
        end
        LaneData.Infv = [LaneData.Infv, z];
        if LaneFact == 2
            LaneData.Infv2 = [LaneData.Infv2, z2];
        end
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
    elseif LaneFact == 2
        LaneData.Lane = ones(NumInf,1);
        LaneData.InfNum = repmat(1:NumInf,1,NumLanes);
        LaneData.Name = repmat(LaneData.Name,1,NumLanes);
         for i = 2:NumLanes
            LaneData.Infv = [LaneData.Infv, LaneData.Infv2];
            LaneData.Lane = [LaneData.Lane; i*ones(NumInf,1)];
        end
    else
        % With transverse consideration, each line must be scaled per lane
        LaneData.Infv = LaneData.Infv*LaneFact(1);
        LaneData.Lane = ones(NumInf,1);
        LaneData.Name = repmat(LaneData.Name,1,length(LaneFact));
        LaneData.InfNum = repmat(1:NumInf,1,length(LaneFact));
        for i = 2:length(LaneFact)
            LaneData.Infv = [LaneData.Infv, LaneData.Infv*LaneFact(i)/LaneFact(1)];
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
    if LaneFact == 2
        LaneData = rmfield(LaneData,'Infv2');
    end
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

