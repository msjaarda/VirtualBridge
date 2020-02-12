function [m] = StartProgBar(NumSims, NumBatches, g, TotalLoops)
%GETKEYVARS Grabs key variables

if NumSims < 10
    Num = NumSims*NumBatches;
    if Num < 100
        m = Num;
    else
        K = 1:ceil(Num/2); D = [K(rem(Num,K)==0) Num];
        ind = interp1(D,1:length(D),100,'nearest');
        m = D(ind);  
    end
elseif NumSims < 100
    m = NumSims;
elseif mod(NumSims/100,1) == 0
    m = 100;
else
    K = 1:ceil(NumSims/2); D = [K(rem(NumSims,K)==0) NumSims];
    ind = interp1(D,1:length(D),100,'nearest');
    m = D(ind);    
end

fprintf(['Progress ' num2str(g) '/' num2str(TotalLoops) ':']); fprintf(['\n' repmat('.',1,m) '\nStarting']);

end

