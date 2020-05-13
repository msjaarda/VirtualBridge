function SaveSummary(TName,filename,TrData,BaseData,Time,UniqInf,FolDist,LaneData,ESIM,ESIA,Ratio,OverMax)
% SaveSummary
% Saves output in Excel in case a manual look is necessary in the future.

% Write all Input file details
TrData.TrLinFit.Properties.VariableNames = {'m1' 'bb1' 'm2' 'bb2' 'm3' 'bb3' 'm4' 'bb4'};
TrData.TrBetAx.Properties.VariableNames = {'AAA1' 'BBB1' 'aaa1' 'bbb1' 'AAA2' 'BBB2' 'aaa2' 'bbb2' 'AAA3' 'BBB3' 'aaa3' 'bbb3'};
TrInput = [TrData.TrDistr, TrData.TrLinFit, TrData.TrAllo, TrData.TrBetAx, TrData.TrWitAx];

warning('OFF', 'MATLAB:xlswrite:AddSheet');
writetable(BaseData,filename,'Sheet',TName,'Range','B9');
writetable(TrInput,filename,'Sheet',TName,'Range','B12');
writetable(FolDist,filename,'Sheet',TName,'Range','B28');
writetable(LaneData,filename,'Sheet',TName,'Range','B34');

[~, b] = xlsfinfo(filename);
if any(strcmp(b, 'Sheet1'))
    xls_delete_sheets(filename,{'Sheet1','Sheet2','Sheet3'});
end

A = {'End Time'; 'Elapsed Time'};
B = {TName; Time}; C = [A B];
writecell(C,filename,'Sheet',TName,'Range','B2');


A = {'Case Name'; 'ESIA'; 'ESIM'; 'Ratio'; 'Mean'; 'Stdev'};
writecell(A,filename,'Sheet',TName,'Range','E2');

writecell(UniqInf',filename,'Sheet',TName,'Range','F2');

writematrix([ESIA; ESIM; Ratio; mean(OverMax); std(OverMax)],filename,'Sheet',TName,'Range','F3');







% % % Copy blank output file and write results
% % copyfile('Output/Output_blank.xlsx',filename)
% % 
% % writecell(UniqInf',filename,'Sheet','MaxLEs','Range','C2');
% % %writematrix([MaxInfv; IntInfv; ESIA; ESIM; ESIA./ESIM-1; mean(OverMax); std(OverMax); OverMax],filename,'Sheet','MaxLEs','Range','C3');
% % writematrix([ESIM; mean(OverMax); std(OverMax); OverMax],filename,'Sheet','MaxLEs','Range','C3');
% % 
% % C = {filename; datetime; ' '; ' '; BaseData.NumVeh;...
% %     BaseData.NumSims; BaseData.TrRate; BaseData.RunDyn; BaseData.RunPlat; BaseData.BunchFactor;...
% %     ''; ''; BatchSize; length(VirtualWIM)/(BaseData.NumSims); length(VirtualWIM)/(BaseData.NumVeh*BaseData.NumSims); ' '; Time};
% % 
% % writecell(C,filename,'Sheet','Summary','Range','C2');
% % 
% % if BaseData.RunPlat == 1
% %     if ~isempty(VirtualWIM)
% %         Num = sum(VirtualWIM(:,6));
% %     else
% %         Num = 0;
% %     end
% %     C = {sum(PlatPct.*TrData.TrDistr.TrDistr); BaseData.PlatSize; BaseData.PlatFolDist;...
% %         Num/(BaseData.PlatSize*BaseData.NumSims); Num/(BaseData.NumSims*sum(PlatPct.*TrData.TrDistr.TrDistr*BaseData.NumVeh*BaseData.TrRate*(LaneTrDistr(1)/100)));...
% %         ''; ''; ''; ''};
% %     writecell(C,filename,'Sheet','Summary','Range','C20');
% % end
% % 

% % 
% % writetable(BaseData,filename,'Sheet','Input','Range','B2');
% % writetable(TrInput,filename,'Sheet','Input','Range','B5');
% % writetable(FolDist,filename,'Sheet','Input','Range','B21');
% % writetable(LaneData,filename,'Sheet','Input','Range','B30');

end