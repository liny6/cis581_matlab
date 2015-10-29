function R  = FindCornerMap(I)
%take an input image I, find the cornerness score of each pixel
%I is a RGB image and points is a n by 2 matrix with x coordinate in column
%1 and y coordinate in column2

[nr, nc] = size(I);
I = padarray(I, [6,6], 'symmetric'); % pad the image with symmetric padding to avoid corners at image's edge

%define kernels
Grad = [1, 0,-1]; %gradient
Gaus = normpdf(-5:1:5, 0, 1); %gaussian

%define patch size (let's try 5x5 equal step function first)
patch= -2:1:2;
patch_size = length(patch);

%smooth out the image and take gradient
I_s = conv2(conv2(I, Gaus, 'valid'), Gaus', 'valid');
I_x = conv2(I_s, Grad, 'valid');
I_x = I_x(2:end-1, :);
I_y = conv2(I_s, Grad', 'valid');
I_y = I_y(:, 2:end-1);

Ix_sq = I_x.^2;
I_xy = I_x.*I_y;
Iy_sq = I_y.^2;

Ix_sq = Ix_sq(:);
Iy_sq = Iy_sq(:);
I_xy = I_xy(:);

%initialize the M matrix
M = zeros(nr, nc, 2, 2);
%initialized shifted indicies
inds = zeros(patch_size, patch_size, nr*nc);
%vectorize shit
[x, y] = meshgrid(1:nc, 1:nr);

for i = 1:patch_size
    x_shifts = x + patch(i);
    x_shifts = max(1, min(x_shifts, nc));
    for j = 1:patch_size
        y_shifts = y + patch(j);
        y_shifts = max(1, min(y_shifts, nr));    
        inds(i, j, :) = sub2ind([nr, nc], y_shifts(:), x_shifts(:));
        %update Matrix      
        M(:, :, 1, 1) = M(:, :, 1, 1) + reshape(Ix_sq(inds(i, j, :)), [nr, nc]);
        M(:, :, 1, 2) = M(:, :, 1, 2) + reshape(I_xy(inds(i, j, :)), [nr, nc]);
        M(:, :, 2, 1) = M(:, :, 1, 2);
        M(:, :, 2, 2) = M(:, :, 2, 2) + reshape(Iy_sq(inds(i, j, :)), [nr, nc]);
    end
end
% R is the 'cornerness score'
detM = M(:, :, 1, 1).*M(:, :, 2, 2) - M(:, :, 1, 2).*M(:, :, 2, 1);
TraceM = M(:, :, 1, 1) + M(:, :, 2, 2);

R = detM./TraceM;

R(isnan(R)) = 0; %condition out the divide by zero

%apply a contrast kernel, this is a hack lololololoololololol
sharp = conv2([-0.35, 1.7, -0.35], [-0.35; 1.7; -0.35]);

R = conv2(R, sharp, 'same');

end

