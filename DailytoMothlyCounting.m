clear
clc
close all
format long g

% -------- INPUT -------- 

% Tell Matlab where the directory is that holds the daily files

% April 1 was a Monday...
% Datetime... might actually know if it is a weekday!

% ----- INPUT -----

Month = 'April';

for i = 1:30

    MFileName = strcat(Month,num2str(i),'.mat');

    load(MFileName);

    if i == 1
        rdm = rd;
    else
        rdm = [rdm;rd];
    end
    
end

save('CH289April2019','rdm');