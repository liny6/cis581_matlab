function [My, Tby] = cumMinEngHor(e)
% e is the energy map.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.

[nx,ny] = size(e);
My = zeros(nx, ny);
Tby = zeros(nx, ny);
My(:,1) = e(:,1);

%% Add your code here

for i = 2:ny
    prev_down = [My(2:end, i-1); inf];
    
    prev_up = [inf; My(2:end, i-1)];
    
    [cost_prev, best] = min([prev_up, My(:,i-1), prev_down], [], 2);
    best_map(:, i) = best;
    My(:, i) = e(:, i) + cost_prev;
end
%backtrack
%start at bottom
[~, ind_best] = min(My(:, ny));
Tby(ind_best, ny) = 1;

for i = (ny-1):-1:1
    switch(best_map(ind_best, i+1))
        
        case 1 
            ind_best = ind_best - 1;
            Tby(ind_best, i) = 1;            
        case 2 
            Tby(ind_best, i) = 1;            
        case 3 
            ind_best = ind_best + 1;
            Tby(ind_best, i) = 1;
    end    
end

end