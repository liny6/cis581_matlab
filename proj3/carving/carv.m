function [Ic, T] = carv(I, nr, nc)
% I is the image being resized
% [nr, nc] is the numbers of rows and columns to remove.
% Ic is the resized image
% T is the transport map

[nx, ny, nz] = size(I);
Cost = zeros(nr+1, nc+1);
TB = zeros(nr+1, nc+1);
T = zeros(nr+1, nc+1);
TI = cell(nr+1, nc+1);
TI{1,1} = I;
% TI is a trace table for images. TI{r+1,c+1} records the image removed r rows and c columns.

%% Add your code here

Ic = TI{nr+1,nc+1};

for i = 1:nr
    for j = 1:nc
        e = genEngMap(TI{i, j});
        %to avoid redundant computation
        [Mx, Tbx] = cumMinEngVer(e);
        [I_v, cost_v] = rmVerSeam(TI{i, j}, Mx, Tbx);
        cuml_cost_v = cost_v + Cost(i,j);
        
        [My, Tby] = cumMinEngHor(e);
        [I_h, cost_h] = rmHorSeam(TI{i, j}, My, Tby);
        cuml_cost_h = cost_h + Cost(i,j);
        
        if isempty(TI{i+1, j})
            TI{i+1, j} = I_v;
            Cost(i+1, j) = cuml_cost_v;
            TB(i+1,j) = 1;
        elseif cuml_cost_v < Cost(i+1, j)         
            TI{i+1, j} = I_v;
            Cost(i+1, j) = cuml_cost_v;
            TB(i+1,j) = 1;
        end
        
        if isempty(TI{i, j+1})
            TI{i, j+1} = I_h;
            Cost(i, j+1) = cuml_cost_h;
            TB(i,j+1) = 2;
        elseif cuml_cost_h < Cost(i, j+1)
            TI{i, j+1} = I_h;
            Cost(i, j+1) = cuml_cost_h;
            TB(i,j+1) = 2;
        end
    end
end

%finishing touches
e = genEngMap(TI{nr, nc+1});
[Mx, Tbx] = cumMinEngVer(e);
[I_v, cost_v] = rmVerSeam(TI{nr, nc+1}, Mx, Tbx);
cuml_cost_v = cost_v + Cost(nr,nc+1);

e = genEngMap(TI{nr+1, nc});
[My, Tby] = cumMinEngVer(e);
[I_h, cost_h] = rmVerSeam(TI{nr+1, nc}, My, Tby);
cuml_cost_h = cost_h + Cost(nr+1,nc);

if cuml_cost_h > cuml_cost_v
    %use vertical
    Ic = I_v;
    TB(nr+1, nc+1) = 1;
else
    Ic = I_h;
    TB(nr+1, nc+1) = 2;
end

%backtrack
k = nr+1;
l = nc+1;
T(k, l) = 1;
while(k~=1 || l~=1)
    if TB(k, l) == 1
        k = k -1;
        T(k, l) = 1;
    else
        l = l -1;
        T(k, l) = 1;
    end
end

end