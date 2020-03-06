function [Flo] = SwapforPlatoons(Flo,BaseData,q,NumTrTyp,PlatPct,TrDistr,BatchSize,Surplus,Lane)
%SWAPFORPLATOONS Does platoon swapping...

% START OF MAJOR PLATOONING EDITION

% FloTrans (TtCtTcCc) = 1,2,3,4 FloPlat = 5 FloPTrail = 6
% FloPLead = 7 FloPPrime = 8 FloSwap = 9

[Flo.Plat, Flo.PTrail, Flo.PLead, Flo.PPrime, Flo.Swap] = deal(false(length(Flo.Veh),1));

% (TtCtTcCc) TO CtTtTcCc

%FloTransTtCtTcCc(:,5:9) = false(length(Flo.Veh),5);

% 2bis) Modify for platooning considerations. Only Lane 1
if BaseData.RunPlat == 1 && q == 1
    for i = 1:NumTrTyp

        % - Start with full platoons (might do empties later)
        % means that PlatPct must be <= .5 because now we
        % define "full" as being over the mean
        % - Make sure candidates are at least n-platsize away
        % from both other platoons and the end of the traffic
        % stream...
        CandidacyStart = false(length(Flo.Veh),1);
        for s = 5:length(Flo.Veh)-BaseData.PlatSize-1
            if Flo.Plat(s+BaseData.PlatSize+1) ~= true
                CandidacyStart(s) = true;
            end
        end
        PlatCand = Flo.Veh == i & Flo.Wgt > prctile(Flo.Wgt(Flo.Veh == i),35) & Flo.Plat == false & Flo.PTrail == false & Flo.PLead == false & CandidacyStart;
        %numPlatCand = sum(PlatCand);
        
        if ~isempty(find(PlatCand, 1))

            for u = 1:round(PlatPct(i)*TrDistr.TrDistr(i)*BatchSize*Surplus*BaseData.TrRate*(Lane.TrDistr(1)/100)/BaseData.PlatSize)

                %   1) Select a random truck to make lead platoon vehicle
                IndOpts = find(PlatCand);
                P1Ind = IndOpts(randi([1 length(IndOpts)]));
                % We need to be sure we won't select P1Ind again... There is a problem here in P1Ind ends up being < 5... tried to fix with candidacystart
                PlatCand(P1Ind) = false;
                PlatCand(P1Ind-1) = false;
                PlatCand(P1Ind-2) = false;
                PlatCand(P1Ind-3) = false;
                PlatCand(P1Ind-4) = false;
                PlatCand(P1Ind+BaseData.PlatSize) = false;
                Flo.Plat(P1Ind) = true;
                % Change properties for vehicle leading platoon
                Flo.PLead(P1Ind-1) = true;
                % Change properties for first platoon vehicle
                Flo.PPrime(P1Ind) = true;
                %PlatCand = Flo.Veh == i & Flo.Wgt > mean(Flo.Wgt(Flo.Veh == i)) & FloTransTtCtTcCc(:,5) == 0 & FloTransTtCtTcCc(:,6) == 0 & FloTransTtCtTcCc(:,7) == 0;
                IndOpts = find(PlatCand);

                for y = 2:BaseData.PlatSize

                    % if the next vehicle in line isn't a candidate itself (normally the case, except by coincidence)
                    if PlatCand(P1Ind+y-1) == false

                        %   2) Find another truck of similar type/fullness
                        PNextInd = IndOpts(randi([1 length(IndOpts)]));

                        % Label as a swap
                        Flo.Swap(PNextInd) = true;

                        %   3) Swap truck from 2) with vehicle behind 1)
                        %   be sure to change Flo.Veh, Flo.Wgt, and Flo.Trans 

                        % Swap Vehicle Type and Weights
                        Flo.Veh([P1Ind+y-1, PNextInd]) = Flo.Veh([PNextInd, P1Ind+y-1]);
                        Flo.Wgt([P1Ind+y-1, PNextInd]) = Flo.Wgt([PNextInd, P1Ind+y-1]);

                        % Swap Following Characteristics at swapped region (not platoon region).
%                         FloTransTtCtTcCc(PNextInd,1:4) = false;
%                         FloTransTtCtTcCc(PNextInd+1,1:4) = false;
                        
                        if Flo.Veh(PNextInd - 1) == 0
                            if Flo.Veh(PNextInd) == 0
                                Flo.Trans(PNextInd) = 2;
                                if Flo.Veh(PNextInd+1) == 0
                                    Flo.Trans(PNextInd+1) = 2;
                                else
                                    Flo.Trans(PNextInd+1) = 1;
                                end
                            else
                                Flo.Trans(PNextInd) = 1;
                                if Flo.Veh(PNextInd+1) == 0
                                    Flo.Trans(PNextInd+1) = -1;
                                else
                                    Flo.Trans(PNextInd+1) = 0;
                                end
                            end
                        else
                            if Flo.Veh(PNextInd) == 0
                                Flo.Trans(PNextInd) = -1;
                                if Flo.Veh(PNextInd+1) == 0
                                    Flo.Trans(PNextInd+1) = 2;
                                else
                                    Flo.Trans(PNextInd+1) = 1;
                                end
                            else
                                Flo.Trans(PNextInd) = 0;
                                if Flo.Veh(PNextInd+1) == 0
                                    Flo.Trans(PNextInd+1) = -1;
                                else
                                    Flo.Trans(PNextInd+1) = 0;
                                end
                            end
                        end

                        % Swap Following properties in platoon
                        Flo.PPrime(P1Ind+y-1) = false;
                        Flo.PLead(P1Ind+y-1) = false;
                        Flo.PTrail(P1Ind+y-1) = false;
                        Flo.Plat(P1Ind+y-1) = true;
                        Flo.Trans(P1Ind+y-1) = 0;

                        % We need to be sure we won't select PNextInd again
                        PlatCand(P1Ind+y-1) = false;
                        PlatCand(PNextInd) = false;
                        IndOpts = find(PlatCand);

                    else

                        % This is the case where no swap is necessary (next vehicle happened to be a candidate)
                        Flo.Plat(P1Ind+y-1) = true;
                        % We need to be sure we won't select PNextInd again
                        PlatCand(P1Ind+y-1) = false;
                        IndOpts = find(PlatCand);

                    end

                    if isempty(IndOpts)
                        fprintf('Warning: Not enough vehicles to form platoon for Truck Type %.0f\n',i)
                        break
                    end

                end

                % At the end we alter vehicle following the platoon
%                 Flo.Plat(P1Ind+BaseData.PlatSize) = false;
%                 Flo.PTrail(P1Ind+BaseData.PlatSize) = false;
                if Flo.Veh(P1Ind+BaseData.PlatSize) == 0
                    Flo.Trans(P1Ind+BaseData.PlatSize) = -1;
                else
                    Flo.Trans(P1Ind+BaseData.PlatSize) = 0;
                end
                Flo.PTrail(P1Ind+BaseData.PlatSize) = true;

            end
        end
    end
end

end

