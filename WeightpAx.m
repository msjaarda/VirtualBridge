function [AxWeights] = WeightpAx(Weight,NumAxpGr,Priority,LinearFits,Allos)
%WeightpAx This function takes in a number of parameters and gives a vector
%of axle weights for a vehicle

% Weight (randomly generated vehicle weights) Num x 1

    
    Num = length(Weight);
    NumAxGr = length(NumAxpGr);
    MaxAx = max(NumAxpGr);
    AxGrWeights = zeros(Num,NumAxGr);
        
    
    % CHANGE 0 limit? note 0.1 at right side...
    for j = Priority
        AxGrWeights(:,j) = max(LinearFits(j,1)*(Weight-sum(AxGrWeights,2)) + LinearFits(j,2),0.1);
    end
    
    AxWMat = zeros(Num,NumAxGr,MaxAx);
    AxWeights = zeros(Num,NumAxGr*MaxAx);
    
    for t = 1:MaxAx %size(Allos',1)
        AxWMat(:,:,t) = Allos(:,t)'.*AxGrWeights;
    end
    
    % You must re-order the columns before deleting the zeros
    count = 1;
    for t = 1:NumAxGr
        for r = 1:MaxAx
            AxWeights(:,count) = AxWMat(:,t,r);
            count = count + 1;
        end
    end
    
    % Delete zeros
    AxWeights = AxWeights(:,any(AxWeights,1));

end