function [NumTrTyp,TrTyp,VWIMCols] = VBGetTrPpties(TrData,FixVars)
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

% Get TableNames for VirtualWIM
AWNames = cell(1,max(TrTyp.NumAx));
WBNames = cell(1,max(TrTyp.NumAx)-1);
for i = 1:max(TrTyp.NumAx)
    AWNames{i} = sprintf('AWT%i',i);
    if i < max(TrTyp.NumAx)
        WBNames{i} = sprintf('W%i_%i',i,i+1);
    end
end

% Get Table Names (Fix for dynamic axle count)
VWIMCols = {'SpCu','LaneVehNum','Type','LANE','DIR','BatchNum','SimNum','LENTH','GW_TOT','AX'};
VWIMCols = [VWIMCols AWNames WBNames];

if FixVars.CarWgt
    % If no cars, add column for 'CarsInfront'
    %LaneVehLineUp = [LaneVehLineUp Flo.CarsInfront];
    VWIMCols{end+1} = 'CarsInfront';
end

end

