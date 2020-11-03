function [Time] = GetSimTime()
%GetSimTime Gets and formats time

Time = seconds(round(toc,2));
if round(toc,0) > 3600
    Time.Format = 'hh:mm:ss';
elseif round(toc,0) > 60
    Time.Format = 'mm:ss';
end

end

