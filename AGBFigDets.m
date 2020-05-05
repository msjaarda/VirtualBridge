function [FName,Section,Config,Dist,AE,Title] = AGBFigDets(Fig)
%AGBFigDets gives figure details according to AGB 2002/005 Report

if Fig == 4.2
    
    % Assign Figure Name
    FName = 'Figure 4.2 Box Girder, Bidirectional';
    
    % Set Plot Parameters
    Section = 'Box'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Bi';   % Bi, Mo
    Dist = 'Split'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE{1} = 'Mn'; AE{2} = 'Mp'; AE{3} = 'V';
    % Set Titles
    Title{1} = 'M-'; Title{2} = 'M+'; Title{3} = 'V';
    
elseif Fig == 4.3
    
    % Assign Figure Name
    FName = 'Figure 4.3 Box Girder, Motorway';
    
    % Set Plot Parameters
    Section = 'Box'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Mo';   % Bi, Mo
    Dist{1} = 'ExFast';  Dist{2} = 'Stand'; Dist{3} = 'ExSlow'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE{1} = 'Mp'; AE{2} = 'Mp'; AE{3} = 'Mp';
    % Set Titles
    Title{1} = 'M+ 85%-15%'; Title{2} = 'M+ 96%-4%'; Title{3} = 'M+ 100%-0%';
    
elseif Fig == 4.4
    
    % Assign Figure Name
    FName = 'Figure 4.4 Twin Girder, Bidirectional';
    
    % Set Plot Parameters
    Section = 'Twin'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Bi';   % Bi, Mo
    Dist = 'Split'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE{1} = 'Mn'; AE{2} = 'Mp'; AE{3} = 'V';
    % Set Titles
    Title{1} = 'M-'; Title{2} = 'M+'; Title{3} = 'V';
    
elseif Fig == 4.5
    
    % Assign Figure Name
    FName = 'Figure 4.5 Twin Girder, Bidirectional';
    
    % Set Plot Parameters
    Section{1} = 'TwinRed'; Section{2} = 'TwinExp'; Section{3} = 'TwinConc'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Bi';   % Bi, Mo
    Dist = 'Split'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE = 'Mp';
    % Set Titles
    Title{1} = 'M+ Reduced'; Title{2} = 'M+ Expanded'; Title{3} = 'M+ Concrete';
    
elseif Fig == 4.6
    
    % Assign Figure Name
    FName = 'Figure 4.6 Twin Girder, Motorway';
    
    % Set Plot Parameters
    Section = 'Twin'; % Box, Twin, TwinRed, TwinExp, TwinConc
    Config = 'Mo';   % Bi, Mo
    Dist{1} = 'ExFast';  Dist{2} = 'Stand'; Dist{3} = 'ExSlow'; % Split, Stand, ExFast, ExSlow
    
    % Set Action Effects
    AE = 'Mp';
    % Set Titles
    Title{1} = 'M+ 85%-15%'; Title{2} = 'M+ 96%-4%'; Title{3} = 'M+ 100%-0%';
    
end

% Convert to cellular if necessary
if ~iscell(Section)
    temp = Section; clear Section; [Section{1:3}] = deal(temp);
end
if ~iscell(AE)
    temp = AE; clear AE; [AE{1:3}] = deal(temp);
end
if ~iscell(Dist)
    temp = Dist; clear Dist; [Dist{1:3}] = deal(temp);
end


end

