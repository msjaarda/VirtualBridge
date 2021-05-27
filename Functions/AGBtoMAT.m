function [AGB] = AGBtoMAT(AGB,GammaS)
%AGBtoMAT The point of this function is to transform the AGB results
%variable into MAT format. This is necessary because TM reported results
%without the gamma factor.

% Set Locations
Loc{1} = 'GD'; Loc{2} = 'MD'; Loc{3} = 'DD'; Loc{4} = 'DetD';
Loc{5} = 'GS'; Loc{6} = 'MS'; Loc{7} = 'DS'; Loc{8} = 'DetS';

Section = fieldnames(AGB);
for i = 1:numel(Section)
    Config = fieldnames(AGB.(Section{i}));
    for j = 1:numel(Config)
        Dist = fieldnames(AGB.(Section{i}).(Config{j}));
        for k = 1:numel(Dist)
            AE = fieldnames(AGB.(Section{i}).(Config{j}).(Dist{k}));
            for p = 1:numel(AE)
                for n = 1:numel(Loc)
                    AGB.(Section{i}).(Config{j}).(Dist{k}).(AE{p}).(Loc{n}) = AGB.(Section{i}).(Config{j}).(Dist{k}).(AE{p}).(Loc{n})*GammaS;
                end
            end
        end
    end
end
                
end