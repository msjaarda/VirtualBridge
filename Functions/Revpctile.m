function centile = Revpctile(XD,Num)
    % Compute centile
    nless = sum(XD < Num);
    nequal = sum(XD == Num);
    centile = 100 * (nless + 0.5*nequal) / length(XD);
end