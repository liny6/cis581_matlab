function E = cannyEdge(I)
%% Canny edge detector
%  Input: A color image I = uint8(X, Y, 3), where X, Y are two dimensions
%  of the image
%  Output: An edge map E = logical(X, Y)
%%  To DO: Write three functions findDerivatives, nonMaxSup, and edgeLink to fulfill the Canny edge detector.

%% Convert the color image to gray scale image
%  Output I = uint8(X, Y)
I = rgb2gray(I);

%% Construct 2D Gaussian filter
Gx = normpdf([-5:1:5], 0, 1);
Gy = normpdf([-5:1:5], 0, 1)';

%% Compute magnitutde and orientation of derivatives
%  J = double(X, Y), the magnitude of derivatives
%  theta = double(X, Y), the orientation of derivatives
%  Jx = double(X, Y), the magnitude of derivatives along x-axis
%  Jy = double(X, Y), the magnitude of derivatives along y-axis
[J, theta, Jx, Jy] = findDerivatives(I, Gx, Gy);

visDerivatives(I, J, Jx, Jy);


%% Detect local maximum
%  M = logical(X, Y), the edge map after non-maximal suppression
M = nonMaxSup(J, theta);
figure; imagesc(M); colormap(gray);

%% Link edges
%  E = logical(X, Y), the final edge map
E = edgeLink(M, J, theta);
figure; imagesc(E); colormap(gray);

end

function [J, theta, Jx, Jy] = findDerivatives(I, Gx, Gy)
    %define derivative kernel
    ddx = [1, 0, -1];
    ddy = ddx';
    %convolve the kernel with derivative
    Gx = conv2(Gx, ddx);
    Gy = conv2(Gy, ddy);
    
    %calculate final kernel size to pad array correctly
    G_sizex = numel(Gx);
    G_sizey = numel(Gy);
    
    pad_sizex = double(G_sizex - 1)/2;
    pad_sizey = double(G_sizey - 1)/2;
    
    %first pad the image depending on the kernel size
    I_padded_x = double(padarray(I, [0, pad_sizex], 'symmetric'));
    I_padded_y = double(padarray(I, [pad_sizey, 0], 'symmetric'));
    %get the gradients
    Jx = conv2(I_padded_x, Gx, 'valid');
    Jy = conv2(I_padded_y, Gy, 'valid');
    %calculate theta
    angle = atan2(Jy, Jx);
    %% Edge angle conditioning
    angle(angle<0) = pi+angle(angle<0);
    angle(angle>7*pi/8) = pi-angle(angle>7*pi/8);
    % Edge angle discretization into 0, pi/4, pi/2, 3*pi/4
    angle(angle>=0&angle<pi/8) = 0;
    angle(angle>=pi/8&angle<3*pi/8) = pi/4;
    angle(angle>=3*pi/8&angle<5*pi/8) = pi/2;
    angle(angle>=5*pi/8&angle<=7*pi/8) = 3*pi/4;
    theta = angle;
    %calculate magnitude
    J = sqrt(Jx.^2 + Jy.^2);
end

function M = nonMaxSup(J, theta)

[nr, nc] = size(J);
[x, y] = meshgrid(1:nc, 1:nr);

right = x + 1;
right = min(nc, max(1, right));
left = x - 1;
left = min(nr, max(1, left));
up = y - 1;
up = min(nr, max(1, up));
down = y + 1;
down = min(nr, max(1, down));

ind_right = sub2ind([nr, nc], y(:), right(:));
ind_left = sub2ind([nr, nc], y(:), left(:));
ind_up = sub2ind([nr, nc], up(:), x(:));
ind_down = sub2ind([nr, nc], down(:), x(:));
ind_ru = sub2ind([nr, nc], up(:), right(:));
ind_lu = sub2ind([nr, nc], up(:), left(:));
ind_rd = sub2ind([nr, nc], down(:), right(:));
ind_ld = sub2ind([nr, nc], down(:), left(:));

J_vec = J(:);

theta_vec = theta(:);

theta_vec_lr = bsxfun(@eq, theta_vec, 0); %entries in the J matrix that has theta at 0 degrees
theta_vec_ruld = bsxfun(@eq, theta_vec, pi/4);
theta_vec_ud = bsxfun(@eq, theta_vec, pi/2);
theta_vec_lurd = bsxfun(@eq, theta_vec, 3*pi/4);

J_lr = theta_vec_lr.*J_vec;
J_ruld = theta_vec_ruld.*J_vec; %right up
J_ud = theta_vec_ud.*J_vec; % yadda yadda...
J_lurd = theta_vec_lurd.*J_vec;

M = bsxfun(@and, bsxfun(@and, (J_lr > J_vec(ind_right)), (J_lr > J_vec(ind_ru))), ...
    bsxfun(@and, (J_lr > J_vec(ind_left)), (J_lr > J_vec(ind_ld)))) ...
    +  bsxfun(@and, bsxfun(@and, (J_ruld > J_vec(ind_ru)), (J_ruld > J_vec(ind_up))), ...
    bsxfun(@and, (J_ruld > J_vec(ind_ld)), (J_ruld > J_vec(ind_down)))) ...
    +  bsxfun(@and, bsxfun(@and, (J_ud > J_vec(ind_up)), (J_ud > J_vec(ind_lu))), ...
    bsxfun(@and, (J_ud > J_vec(ind_down)), (J_ud > J_vec(ind_rd)))) ...
    +  bsxfun(@and, bsxfun(@and, (J_lurd > J_vec(ind_lu)), (J_lurd > J_vec(ind_left))), ...
    bsxfun(@and, (J_lurd > J_vec(ind_left)), (J_lurd > J_vec(ind_rd))));

M = reshape(M, [nr, nc]);
end

function E = edgeLink(M, J, theta)

J_sup = J.* M;
[nr, nc] = size(J);

high = 30;
low = 3;

J_high = bsxfun(@ge, J_sup, high);
J_low = bsxfun(@ge, bsxfun(@le, J_sup, high), low);

%vectorize

[x, y] = meshgrid(1:nc, 1:nr);

right = x + 1;
right = min(nc, max(1, right));
left = x - 1;
left = min(nr, max(1, left));
up = y - 1;
up = min(nr, max(1, up));
down = y + 1;
down = min(nr, max(1, down));

ind_right = sub2ind([nr, nc], y(:), right(:));
ind_left = sub2ind([nr, nc], y(:), left(:));
ind_up = sub2ind([nr, nc], up(:), x(:));
ind_down = sub2ind([nr, nc], down(:), x(:));
ind_ru = sub2ind([nr, nc], up(:), right(:));
ind_lu = sub2ind([nr, nc], up(:), left(:));
ind_rd = sub2ind([nr, nc], down(:), right(:));
ind_ld = sub2ind([nr, nc], down(:), left(:));

theta_vec = theta(:);

theta_vec_lr = bsxfun(@eq, theta_vec, 0); %entries in the J matrix that has theta at 0 degrees
theta_vec_ruld = bsxfun(@eq, theta_vec, pi/4);
theta_vec_ud = bsxfun(@eq, theta_vec, pi/2);
theta_vec_lurd = bsxfun(@eq, theta_vec, 3*pi/4);

J_high = J_high(:);
J_low = J_low(:);

J_low_lr = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_right)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_left)));
J_low_ruld = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_ru)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_ld)));
J_low_ud = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_up)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_down)));
J_low_lurd = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_lu)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_rd)));

J_low_valid = bsxfun(@or, bsxfun(@or, J_low_lr, J_low_ruld), bsxfun(@or, J_low_ud, J_low_lurd));

E = J_high + J_low_valid;

E = reshape(E, [nr, nc]);

end