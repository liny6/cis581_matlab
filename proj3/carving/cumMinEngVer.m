function [Mx, Tbx] = cumMinEngVer(e)
% e is the energy map.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.

[nx,ny] = size(e);
Mx = zeros(nx, ny);
Tbx = zeros(nx, ny);
best_map = zeros(nx, ny);
Mx(1,:) = e(1,:);

%% Add your code here

%calculate accumulated energy
for i = 2:nx
    ind_right = (1:ny) + 1;
    prev_right = [Mx(i-1, ind_right(1:end-1)), inf];
    
    ind_left = (1:ny) - 1;
    prev_left = [inf, Mx(i-1, ind_left(2:end))];
    
    [cost_prev, best] = min([prev_left; Mx(i-1, :); prev_right]);
    best_map(i, :) = best;
    Mx(i, :) = e(i, :) + cost_prev;
end
%backtrack
%start at bottom
[~, ind_best] = min(Mx(nx, :));
Tbx(nx, ind_best) = 1;

for i = (nx-1):-1:1
    switch(best_map(i+1, ind_best))
        
        case 1 
            ind_best = ind_best - 1;
            Tbx(i, ind_best) = 1;            
        case 2 
            Tbx(i, ind_best) = 1;            
        case 3 
            ind_best = ind_best + 1;
            Tbx(i, ind_best) = 1;
    end    
end

end