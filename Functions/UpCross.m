function [Num] = UpCross(Data,v)
%UpCross Calculate the number of upcrossings of a certain value, v, in a
%dataset, Data

% Original Data and circshifted data
DataS = circshift(Data,1);

if size(Data,2) == 1 || size(Data,1) == 1
    if size(v,2) > size(v,1)
        v = v';
    end
    if size(Data,2) < size(Data,1)
        Data = Data';
        DataS = DataS';
    end
    
    Num = sum(DataS <= v & v < Data,2);
else
    for j = 1:size(Data,2)
        DataP = Data(:,j);
        DataSP = DataS(:,j);
        
        if size(v,2) < size(v,1)
            v = v';
        end
        
        Num(:,j) = sum(DataSP <= v & v < DataP,1);
    end    
end

% What if you don't need to provide v?










end

