function [Ix, E] = rmVerSeam(I, Mx, Tbx)
% I is the image. Note that I could be color or grayscale image.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.
% Ix is the image removed one column.
% E is the cost of seam removal

E = sum(Mx(logical(Tbx)));

[nx, ny, nz] = size(I);

[~, rmidx] = max(Tbx, [], 2);

Ix = zeros(nx, ny-1, nz);

for i = 1:nx
    Ix(i, :, :) = [I(i, 1:(rmidx(i)-1), :), I(i, (rmidx(i)+1):end, :)] ;
end

Ix = uint8(Ix);
end