function [FloVeh, FloTrans] = GetFloVeh(LaneNumVeh,TrTrTransProb,CarCarTransProb,BunchFactor,q,NumTrTyp,TrDistCu)
% % % %GETFLOVEH Summary of this function goes here
% % % 
% % % % TC is a truck, followed by a car (<<<Truck<<Car)
% % % 
% % % % 1) Cars = 0 and Trucks = 1-NumTrTyp
% % % % Initialize Vehicle Stream vector and transition logicals
% % % 
% % % FloVeh = false(LaneNumVeh(q),1);
% % % FloTransTtCtTcCc = false(LaneNumVeh(q),4);
% % % 
% % % % Define vehicle type with Cars = 0 and Trucks = 1
% % % if BunchFactor == 1
% % %     
% % %     % Random decision variable
% % %     FloVeh(rand(LaneNumVeh(q),1) < TrTrTransProb(q)) = true;
% % %     
% % %     % TO BE IMPLEMENTED AFTER CHANGING to -1,0,1,2
% % % %     FloTransTtCtTcCc = diff(FloVeh);
% % % %     FloTransTtCtTcCc(FloTransTtCtTcCc==0 & FloVeh(1:end-1)==0) = 2;
% % %     % 1
% % %     
% % %     % First vehicle must always be a car... to avoid subscript of zero later
% % %     FloVeh(1) = false;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == -1,2) = true;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == 1,3) = true;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == 0 & FloVeh == 1,1) = true;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == 0 & FloVeh == 0,4) = true;
% % %     
% % % else
% % %     
% % %     for i = 2:LaneNumVeh(q)
% % %         % Step through and use previous vehicle to determine current vehicle
% % %         if ~FloVeh(i-1)                    % Car (previous)
% % %             if rand > CarCarTransProb(q)
% % %                 FloVeh(i) = true;                  % Truck (current)
% % %                 %FloTransTtCtTcCc(i,3) = true;            % Car followed by Truck (CT)
% % %                 %else
% % %                 %    FloTransTtCtTcCc(i,4) = true;            % Car followed by Car (CC)
% % %             end
% % %         else                                    % Truck (previous)
% % %             if rand < TrTrTransProb(q)
% % %                 FloVeh(i) = true;                  % Truck (current)
% % %                 %   FloTransTtCtTcCc(i,1) = true;            % Truck followed by Truck (TT)
% % %                 %else
% % %                 %    FloTransTtCtTcCc(i,2) = true;            % Truck followed by Car (TC)
% % %             end
% % %         end
% % %     end
% % %     
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == -1,2) = true;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == 1,3) = true;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == 0 & FloVeh == 1,1) = true;
% % %     FloTransTtCtTcCc(FloVeh - circshift(FloVeh,1) == 0 & FloVeh == 0,4) = true;
% % %     
% % % end
% % % 
% % % % We can now define the number of cars and trucks
% % % NumTr = sum(FloVeh == 1);
% % % % TrRatex(q) = NumTr(k,q)/LaneNumVeh(q); % Use for troubleshooting
% % % 
% % % % Now go more advanced with Cars = 0 and Trucks = 1 to NumTrTyp
% % % 
% % % % Note: Non-classified trucks accounted for in input distribution
% % % % Create Random Decider vector
% % % RanDec = rand(NumTr,1);
% % % RanDecx = zeros(NumTr,1);
% % % 
% % % % Split the RanDecx random decider pie into Truck Types
% % % for i = 1:NumTrTyp
% % %     RanDecx(RanDec < TrDistCu(i)) = i;   
% % %     RanDec(RanDec < TrDistCu(i)) = 2;         % Just change to something > 1
% % % end
% % % 
% % % % All the trucks in flow are now assigned truck types
% % % FloVeh(FloVeh == 1) = RanDecx;








%GETFLOVEH Summary of this function goes here

% TC is a truck, followed by a car (<<<Truck<<Car)

% 1) Cars = 0 and Trucks = 1-NumTrTyp
% Initialize Vehicle Stream vector and transition logicals

FloVeh = zeros(LaneNumVeh(q),1);

% Define vehicle type with Cars = 0 and Trucks = 1
if BunchFactor == 1
    
    % Random decision variable
    FloVeh(rand(LaneNumVeh(q),1) < TrTrTransProb(q)) = 1;
    
    % TO BE IMPLEMENTED AFTER CHANGING to -1,0,1,2
%     FloTransTtCtTcCc = diff(FloVeh);
%     FloTransTtCtTcCc(FloTransTtCtTcCc==0 & FloVeh(1:end-1)==0) = 2;
    % 1
    
    % First vehicle must always be a car... to avoid subscript of zero later
    FloVeh(1) = 0;
    % TtCtTcCc is now CtTtTcCc
    FloTrans = [2; diff(FloVeh)];
    FloTrans(FloTrans == 0 & FloVeh == 0) = 2;
    
else
    
    for i = 2:LaneNumVeh(q)
        % Step through and use previous vehicle to determine current vehicle
        if ~FloVeh(i-1)                    % Car (previous)
            if rand > CarCarTransProb(q)
                FloVeh(i) = 1;                  % Truck (current)
                %FloTransTtCtTcCc(i,3) = true;            % Car followed by Truck (CT)
                %else
                %    FloTransTtCtTcCc(i,4) = true;            % Car followed by Car (CC)
            end
        else                                    % Truck (previous)
            if rand < TrTrTransProb(q)
                FloVeh(i) = 1;                  % Truck (current)
                %   FloTransTtCtTcCc(i,1) = true;            % Truck followed by Truck (TT)
                %else
                %    FloTransTtCtTcCc(i,2) = true;            % Truck followed by Car (TC)
            end
        end
    end
    
    FloTrans = [2; diff(FloVeh)];
    FloTrans(FloTrans == 0 & FloVeh == 0) = 2;
    
end

% We can now define the number of cars and trucks
NumTr = sum(FloVeh == 1);
% TrRatex(q) = NumTr(k,q)/LaneNumVeh(q); % Use for troubleshooting

% Now go more advanced with Cars = 0 and Trucks = 1 to NumTrTyp

% Note: Non-classified trucks accounted for in input distribution
% Create Random Decider vector
RanDec = rand(NumTr,1);
RanDecx = zeros(NumTr,1);

% Split the RanDecx random decider pie into Truck Types
for i = 1:NumTrTyp
    RanDecx(RanDec < TrDistCu(i)) = i;   
    RanDec(RanDec < TrDistCu(i)) = 2;         % Just change to something > 1
end

% All the trucks in flow are now assigned truck types
FloVeh(FloVeh == 1) = RanDecx;







end

