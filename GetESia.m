function [ESIA] = GetESia(IntInfv,MaxInfv,InfLanes,UniqInfs)
%GetESia

ESIA = zeros(1,length(UniqInfs));

for i = 1:length(UniqInfs)
    if InfLanes(UniqInfs(i)) == 0
        ESIA(i) = 1.5*.9*(MaxInfv(UniqInfs(i))*2*500+3*9*IntInfv(UniqInfs(i))+3*2.5*2*IntInfv(UniqInfs(i)));
    else
       % For now... unless we want to put in the third lane influence line.
        ESIA(i) = 1;
    end
end
  
end