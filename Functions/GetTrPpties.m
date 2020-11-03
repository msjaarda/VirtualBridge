function [NumTrTyp,TrTyp] = GetTrPpties(TrData)
%GETTRPPTIES Grabs truck properties

NumTrTyp = height(TrData.TrDistr);
TrTyp.DistCu = cumsum(TrData.TrDistr.TrDistr); 

[TrTyp.NumAxPerGr, TrTyp.Priority, TrTyp.LinFit,  TrTyp.Allos] = deal(cell(NumTrTyp,1));
[TrTyp.NumAx, TrTyp.NumAxGr] = deal(zeros(NumTrTyp,1));

for i = 1:NumTrTyp
    TrTyp.NumAxPerGr{i} = arrayfun(@(x) mod(floor(TrData.TrDistr.TrAxPerGr(i)/10^x),10),floor(log10(TrData.TrDistr.TrAxPerGr(i))):-1:0);
    TrTyp.Priority{i} = arrayfun(@(x) mod(floor(TrData.TrDistr.TrTypPri(i)/10^x),10),floor(log10(TrData.TrDistr.TrTypPri(i))):-1:0);
    TrTyp.NumAx(i) = sum(TrTyp.NumAxPerGr{i});
    TrTyp.NumAxGr(i) = length(TrTyp.NumAxPerGr{i});
    for j = 1:TrTyp.NumAxGr(i)
        TrTyp.LinFit{i}(j,1) = TrData.TrLinFit{i,j*2-1};
        TrTyp.LinFit{i}(j,2) = TrData.TrLinFit{i,j*2};
        for k = 1:max(TrTyp.NumAxPerGr{i})
            TrTyp.Allos{i}(j,k) = TrData.TrAllo{i,k+(j-1)*max(TrTyp.NumAxPerGr{i})};
        end
    end   
end

end

