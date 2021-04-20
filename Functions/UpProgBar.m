function UpProgBar(m, st, v, k, NumSims, NumBatches)
%GETKEYVARS Grabs key variables
t = v;
Num = NumSims;


no = (now-st);
if no > 1
    marker = 'd';
elseif no*24 > 1
    no = no*24;  marker = 'h';
elseif no*24*60 > 1
    no = no*24*60; marker = 'm';
else
    no = no*3600*24; marker = 's';
end



if NumSims < 10
    t = v*k;
    Num = NumSims*NumBatches;
    if Num < 100
        % Update progress bar
        if mod(t,Num/m) == 0
            if numel(num2str(floor(no))) == 2
                fprintf('\b\b\b\b\b\b\b\b|%s%.2f%s\n',' ',no,marker);
            else
                fprintf('\b\b\b\b\b\b\b\b|%s%.2f%s\n','  ',no,marker);
            end
        end
    else
        % Update progress bar
        if mod(t,Num/m) == 0
            if numel(num2str(floor(no))) == 2
                fprintf('\b\b\b\b\b\b\b\b|%s%.2f%s\n',' ',no,marker);
            else
                fprintf('\b\b\b\b\b\b\b\b|%s%.2f%s\n','  ',no,marker);
            end
        end
    end
    
elseif k == max(NumBatches)
    
    % Update progress bar
    if mod(t,Num/m) == 0
        if numel(num2str(floor(no))) == 2
            fprintf('\b\b\b\b\b\b\b\b|%s%.2f%s\n',' ',no,marker);
        else
            fprintf('\b\b\b\b\b\b\b\b|%s%.2f%s\n','  ',no,marker);
        end
        
    end
    
end

end
