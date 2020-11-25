function [PD] = AddDatetime(PD,DeleteOthers)
% ADDDATETIME This function takes in a processed data WIM table (or processed
% data with classification, PDC), and returns that same table with an extra
% column, Time, which combines columns JJJJMMTT, HHMMSS, and sometimes HH  

PD.Time = datetime(PD.JJJJMMTT, 'ConvertFrom', 'yyyymmdd','Format','yyyy-MM-dd HH:mm:ss.S');

PD.Time = PD.Time + hours(floor(PD.HHMMSS/10000)) + minutes(floor((mod(PD.HHMMSS,10000)/100))) + seconds(mod(PD.HHMMSS,100));

try   
    PD.Time = PD.Time + milliseconds(str2double(PD.HH)*10);    
catch
end

if DeleteOthers == 1
    PD.JJJJMMTT = [];
    PD.HHMMSS = [];
    try
    PD.HH = [];
    catch
    end
end

end

