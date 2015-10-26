function [Iy, E] = rmHorSeam(I, My, Tby)
% I is the image. Note that I could be color or grayscale image.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.
% Iy is the image removed one row.
% E is the cost of seam removal


E = sum(My(logical(Tby)));

[nx, ny, nz] = size(I);

Tby = repmat(Tby, [1, 1, 3]);
Tby = logical(Tby(:));

I = I(:);

Iy = I(~Tby);

Iy = reshape(Iy, [nx-1, ny, nz]);



end