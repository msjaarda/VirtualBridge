function X = ConvertToGLB(PD,Year,Month,StartDay,EndDay)
%CONVERT2GLB Give this function a WIM variable in the classic PD (.mat)
%format and it will return data for a given month in the format required by
%GLB.

% Take only the data for the desired month
PDCx = PD(PD.JJJJMMTT >= Year*10000+Month*100+StartDay & PD.JJJJMMTT <= Year*10000+Month*100+EndDay,:);

% Start a new variable with the columns you want:
PDCx = Daytype(PDCx,Year);

% Fix decimal seconds
PDCx.HH = str2double(PDCx.HH)/100;

% Sort by timestamp
PDCx = sortrows(PDCx,{'JJJJMMTT','HHMMSS','HH'});

% Time diff in seconds
PDCx.TStamp = 60*60*24*(PDCx.Daycount-1) + 60*60*floor(PDCx.HHMMSS/10000) + 60*floor(rem(PDCx.HHMMSS,10000)/100) + rem(PDCx.HHMMSS,100) + PDCx.HH;
PDCx.DeltaT = [0; diff(PDCx.TStamp)];
    
% COLUMN 1: N
X(:,1) = 1:height(PDCx);

% COLUMN 2: V (m/s)
X(:,2) = PDCx.SPEED/100*0.277778;

% COLUMN 3: Load (kN)
X(:,3) = PDCx.GW_TOT*0.00980665;

% COLUMN 4: Distance (m)
X(:,4) = PDCx.DeltaT.*X(:,2);

% COLUMN 5: Cummulative Distance (m)
X(:,5) = cumsum(X(:,4));

end

