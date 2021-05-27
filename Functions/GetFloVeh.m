function [Flo] = GetFloVeh(LaneNumVeh,TransPrTT,TransPrCC,BunchFactor,q,TrDistCu)
%GETFLOVEH Gets Flo.Veh and Flo.Trans

% TC is a truck, followed by a car (<<<Truck<<Car)
%%%                         THIS IS WRONG!!! SEE BELOW... TC means
%%%                         <<<CAR<<<<TRUCK (Truck after car)

% Flo.Trans(i) is the distance INFRONT of vehicle i
% Therefore, TC is the space INFRONT of the car
            %TT is the space INFRONT of the truck (up to the truck)
            %CT is the space INFRONT of the truck (up to the car)
            %CC is the space INFRONT of the car (up to the car)

% Let Cars = 1 and Trucks be 2-NumTrTyp+1 !!!

% 1) Cars = 0 and Trucks = 1-NumTrTyp
% Initialize Vehicle Stream vector and transition logicals
Flo.Veh = zeros(LaneNumVeh(q),1);

% Define vehicle type with Cars = 0 and Trucks = 1
if BunchFactor == 1
    
    % Random decision variable
    Flo.Veh(rand(LaneNumVeh(q),1) < TransPrTT(q)) = 1;
       
    % First vehicle must always be a car... to avoid subscript of zero later
    % Changed from 0 to 1 or 0... see if it ever causes an error! not so
    % far... could remove
    Flo.Veh(1) = randi(2) -1;
    % Place a random number at the start (doesn't matter... who knows what
    % vehicle is infront of this vehicle stream!)
    Flo.Trans = [2; diff(Flo.Veh)];
    Flo.Trans(Flo.Trans == 0 & Flo.Veh == 0) = 2;
    
else
    
    for i = 2:LaneNumVeh(q)
        % Step through and use previous vehicle to determine current vehicle
        if ~Flo.Veh(i-1)                    % Car (previous)
            if rand > TransPrCC(q)
                Flo.Veh(i) = 1;             % Truck (current)
            end
        else                                % Truck (previous)
            if rand < TransPrTT(q)
                Flo.Veh(i) = 1;             % Truck (current)
            end
        end
    end
    
    Flo.Trans = [2; diff(Flo.Veh)];
    Flo.Trans(Flo.Trans == 0 & Flo.Veh == 0) = 2;
    
end

% We can now define the number of cars and trucks
NumTr = sum(Flo.Veh == 1);

% TrRatex(q) = NumTr/LaneNumVeh(q); % Use for troubleshooting

% Now go more advanced with Cars = 0 and Trucks = 1 to NumTrTyp

% Create Random Decider vector
RanDec = rand(NumTr,1);
RanDecx = zeros(NumTr,1);

% Split the RanDecx random decider pie into Truck Types
for i = 1:length(TrDistCu)
    RanDecx(RanDec < TrDistCu(i)) = i;   
    RanDec(RanDec < TrDistCu(i)) = 2;         % Just change to something > 1
end

% All the trucks in flow are now assigned truck types
Flo.Veh(Flo.Veh == 1) = RanDecx;

end

