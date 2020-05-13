function [] = LaneDistBr(PDC,TrTyps,TrAxPerGr,Station)
% This function used in the MATSim input file pipeline
% Lane Distribution Breakdown (truck axle number in each lane)


NumTrTyp = length(TrTyps);
TrNumAx = zeros(length(NumTrTyp),1);

for i = 1:NumTrTyp    % For each truck type
    TrTypNumAxPerGr{i} = arrayfun(@(x) mod(floor(TrAxPerGr(i)/10^x),10),floor(log10(TrAxPerGr(i))):-1:0);
    TrNumAx(i) = sum(TrTypNumAxPerGr{i});
end

fprintf('\nTruck Lane Distribution (Percentages):\n\n')

% Summarize lane distribution based on the # of axles (see 2.4.3)
for i = 1:length(Station)
    t = unique(PDC.FS(PDC.ZST == Station(i)));

    for j = 1:length(t)
        
        Avg(i,j) = sum(PDC.ZST == Station(i) & PDC.FS == t(j));
        
%         Opts = TrTyps(TrNumAx == 2 | TrNumAx == 3 | TrNumAx == 4 | TrNumAx == 5 | TrNumAx == 6);
%         TTx(i,j) = 0;
%         for k = 1:length(Opts)
%             TTx(i,j) = TTx(i,j) + sum(PDC.ZST == Station(i) & PDC.FS == t(i,j) & PDC.CLASS == Opts(k));
%         end

        TTx(i,j) = sum(PDC.ZST == Station(i) & PDC.FS == t(j) & (PDC.AX == 2 | PDC.AX == 3));
        
%         Opts = TrTyps(TrNumAx == 4);
%         Fx(i,j) = 0;
%         for k = 1:length(Opts)
%             Fx(i,j) = Fx(i,j) + sum(PDC.ZST == Station(i) & PDC.FS == t(i,j) & PDC.CLASS == Opts(k));
%         end
        
        Fx(i,j) = sum(PDC.ZST == Station(i) & PDC.FS == t(j) & (PDC.AX == 4));
        
%         Opts = TrTyps(TrNumAx == 5 | TrNumAx == 6);
%         FSx(i,j) = 0;
%         for k = 1:length(Opts)
%             FSx(i,j) = FSx(i,j) + sum(PDC.ZST == Station(i) & PDC.FS == t(i,j) & PDC.CLASS == Opts(k));
%         end
        
        FSx(i,j) = sum(PDC.ZST == Station(i) & PDC.FS == t(j) & (PDC.AX == 5 | PDC.AX == 6));
    end
    
    fprintf('Station %i Avg: \t\t\t%.2f\n',Station(i),100*(max(Avg(i,:))/sum(Avg(i,:))))
    fprintf('Station %i 2 & 3 Axles: \t%.2f\n',Station(i),100*(max(TTx(i,:))/sum(TTx(i,:))))
    fprintf('Station %i 4 Axles: \t\t%.2f\n',Station(i),100*(max(Fx(i,:))/sum(Fx(i,:))))
    fprintf('Station %i 5 & 6 Axles: \t%.2f\n\n',Station(i),100*(max(FSx(i,:))/sum(FSx(i,:))))
    
end


end