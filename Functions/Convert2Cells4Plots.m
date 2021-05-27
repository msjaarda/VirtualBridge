function [Section,AE,Dist,Loc] = Convert2Cells4Plots(Section,AE,Dist,Loc)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~iscell(Section)
    temp = Section; clear Section; [Section{1:3}] = deal(temp);
end
if ~iscell(AE)
    temp = AE; clear AE; [AE{1:3}] = deal(temp);
end
if ~iscell(Dist)
    temp = Dist; clear Dist; [Dist{1:3}] = deal(temp);
end
if ~iscell(Loc)
    temp = Loc; clear Loc; [Loc{1:3}] = deal(temp);
end

end

