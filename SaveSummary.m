function SaveSummary(InputFile,BaseData,BatchSize,PlatPct,TrData,VirtualWIM,Time,UniqInf,FolDist,LaneData,ESIM,OverMax,LaneTrDistr)
%xSAVEUMMARY Print summary of program output
%   Detailed explanation goes here

% Copy blank output file and write results
filename = strcat('Output/MATSimOutput', InputFile(1:end-5),'_',datestr(now,'mmmdd-yy HHMM'), '.xlsx');
copyfile('Output/Output_blank.xlsx',filename)

writecell(UniqInf',filename,'Sheet','MaxLEs','Range','C2');
%writematrix([MaxInfv; IntInfv; ESIA; ESIM; ESIA./ESIM-1; mean(OverMax); std(OverMax); OverMax],filename,'Sheet','MaxLEs','Range','C3');
writematrix([ESIM; mean(OverMax); std(OverMax); OverMax],filename,'Sheet','MaxLEs','Range','C3');

C = {InputFile(18:end-5); datetime; ' '; ' '; BaseData.NumVeh;...
    BaseData.NumSims; BaseData.TrRate; BaseData.RunDyn; BaseData.RunPlat; BaseData.BunchFactor;...
    ''; ''; BatchSize; length(VirtualWIM)/(BaseData.NumSims); length(VirtualWIM)/(BaseData.NumVeh*BaseData.NumSims); ' '; Time};

writecell(C,filename,'Sheet','Summary','Range','C2');

if BaseData.RunPlat == 1
    if ~isempty(VirtualWIM)
        Num = sum(VirtualWIM(:,6));
    else
        Num = 0;
    end
    C = {sum(PlatPct.*TrData.TrDistr.TrDistr); BaseData.PlatSize; BaseData.PlatFolDist;...
        Num/(BaseData.PlatSize*BaseData.NumSims); Num/(BaseData.NumSims*sum(PlatPct.*TrData.TrDistr.TrDistr*BaseData.NumVeh*BaseData.TrRate*(LaneTrDistr(1)/100)));...
        ''; ''; ''; ''};
    writecell(C,filename,'Sheet','Summary','Range','C20');
end

% Write all Input file details
TrData.TrLinFit.Properties.VariableNames = {'m1' 'bb1' 'm2' 'bb2' 'm3' 'bb3' 'm4' 'bb4'};
TrData.TrBetAx.Properties.VariableNames = {'AAA1' 'BBB1' 'aaa1' 'bbb1' 'AAA2' 'BBB2' 'aaa2' 'bbb2' 'AAA3' 'BBB3' 'aaa3' 'bbb3'};
TrInput = [TrData.TrDistr, TrData.TrLinFit, TrData.TrAllo, TrData.TrBetAx, TrData.TrWitAx];

writetable(BaseData,filename,'Sheet','Input','Range','B2');
writetable(TrInput,filename,'Sheet','Input','Range','B5');
writetable(FolDist,filename,'Sheet','Input','Range','B21');
writetable(LaneData,filename,'Sheet','Input','Range','B30');

end