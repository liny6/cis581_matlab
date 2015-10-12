function E = cannyEdge(I)
close all
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
    theta = angle;
    %calculate magnitude
    J = sqrt(Jx.^2 + Jy.^2);
end

function M = nonMaxSup(J, theta)

angle = theta;
% Edge angle discretization into 0, pi/4, pi/2, 3*pi/4
%{
angle(angle>=0&angle<pi/4) = 0;
angle(angle>=pi/4&angle<pi/2) = pi/4;
angle(angle>=pi/2&angle<3*pi/4) = pi/2;
angle(angle>=3*pi/4&angle<=pi) = 3*pi/4;
%}
angle(angle>=0 & angle<pi/8) = 0;
angle(angle>=pi/8 & angle<3*pi/8) = pi/4;
angle(angle>=3*pi/8 & angle<5*pi/8) = pi/2;
angle(angle>=5*pi/8 & angle<=pi) = 3*pi/4;


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

angle_vec = angle(:);
theta_vec = theta(:);

theta_vec_lr = bsxfun(@eq, angle_vec, 0); %entries in the J matrix that has theta at 0 degrees
theta_vec_ruld = bsxfun(@eq, angle_vec, pi/4);
theta_vec_ud = bsxfun(@eq, angle_vec, pi/2);
theta_vec_lurd = bsxfun(@eq, angle_vec, 3*pi/4);

J_lr = theta_vec_lr.*J_vec;
J_ruld = theta_vec_ruld.*J_vec; %right up
J_ud = theta_vec_ud.*J_vec; % yadda yadda...
J_lurd = theta_vec_lurd.*J_vec;

%{
M = bsxfun(@and, bsxfun(@and, (J_lr > J_vec(ind_right)), (J_lr > J_vec(ind_ru))), ...
    bsxfun(@and, (J_lr > J_vec(ind_left)), (J_lr > J_vec(ind_ld)))) ...
    +  bsxfun(@and, bsxfun(@and, (J_ruld > J_vec(ind_ru)), (J_ruld > J_vec(ind_up))), ...
    bsxfun(@and, (J_ruld > J_vec(ind_ld)), (J_ruld > J_vec(ind_down)))) ...
    +  bsxfun(@and, bsxfun(@and, (J_ud > J_vec(ind_up)), (J_ud > J_vec(ind_lu))), ...
    bsxfun(@and, (J_ud > J_vec(ind_down)), (J_ud > J_vec(ind_rd)))) ...
    +  bsxfun(@and, bsxfun(@and, (J_lurd > J_vec(ind_lu)), (J_lurd > J_vec(ind_left))), ...
    bsxfun(@and, (J_lurd > J_vec(ind_left)), (J_lurd > J_vec(ind_rd))));
%}

lr_inter = max(J_vec(ind_right).*(1-sin(theta_vec)) + J_vec(ind_ru).*(sin(theta_vec)), J_vec(ind_left).*(1-sin(theta_vec)) + J_vec(ind_ld).*(sin(theta_vec)));
ruld_inter = max(J_vec(ind_up).*(1-cos(theta_vec)) + J_vec(ind_ru).*(cos(theta_vec)), J_vec(ind_down).*(1-cos(theta_vec)) + J_vec(ind_ld).*(cos(theta_vec)));
ud_inter = max(J_vec(ind_up).*(1+cos(theta_vec)) + J_vec(ind_lu).*(-cos(theta_vec)), J_vec(ind_down).*(1+cos(theta_vec)) + J_vec(ind_rd).*(-cos(theta_vec)));
lurd_inter = max(J_vec(ind_left).*(1-sin(theta_vec)) + J_vec(ind_lu).*(sin(theta_vec)), J_vec(ind_right).*(1-sin(theta_vec)) + J_vec(ind_rd).*(sin(theta_vec)));



%let's try circular interpolation
%{
lr_inter = max( J_vec(ind_right) + (J_vec(ind_ru) - J_vec(ind_right) .* (theta_vec - 0)), J_vec(ind_left) + (J_vec(ind_ld) - J_vec(ind_left)) .* (theta_vec - 0));
ruld_inter = max( J_vec(ind_ru) + (J_vec(ind_up) - J_vec(ind_ru) .* (theta_vec - pi/4)), J_vec(ind_ld) + (J_vec(ind_down) - J_vec(ind_ld)) .* (theta_vec - pi/4));
ud_inter = max( J_vec(ind_up) + (J_vec(ind_lu) - J_vec(ind_up) .* (theta_vec - pi/2)), J_vec(ind_down) + (J_vec(ind_rd) - J_vec(ind_down)) .* (theta_vec - pi/2));
lurd_inter = max( J_vec(ind_lu) + (J_vec(ind_left) - J_vec(ind_lu) .* (theta_vec - 3*pi/4)), J_vec(ind_rd) + (J_vec(ind_right) - J_vec(ind_rd)) .* (theta_vec - 3*pi/4));
%}
M = bitor(bitor((J_lr >= lr_inter),(J_ruld >= ruld_inter)), bitor((J_ud >= ud_inter),(J_lurd >= lurd_inter)));

M = reshape(M, [nr, nc]);
end

function E = edgeLink(M, J, theta)

% Edge angle discretization into 0, pi/4, pi/2, 3*pi/4
    theta(theta>=0&theta<pi/8) = 0;
    theta(theta>=pi/8&theta<3*pi/8) = pi/4;
    theta(theta>=3*pi/8&theta<5*pi/8) = pi/2;
    theta(theta>=5*pi/8&theta<=pi) = 7*pi/8;

J_sup = J.* M;
[nr, nc] = size(J);

high = sqrt(max(max(J_sup)))*3.8;
low = high/4;

J_high = bsxfun(@ge, J_sup, high);
J_low = bitand(bsxfun(@ge, J_sup, low), bsxfun(@le, J_sup, high));

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

%{
theta_vec_lr = bsxfun(@eq, theta_vec, 0); %entries in the J matrix that has theta at 0 degrees
theta_vec_ruld = bsxfun(@eq, theta_vec, pi/4);
theta_vec_ud = bsxfun(@eq, theta_vec, pi/2);
theta_vec_lurd = bsxfun(@eq, theta_vec, 3*pi/4);
%}

theta_vec_lr = bsxfun(@eq, theta_vec, 0); %entries in the J matrix that has theta at 0 degrees
theta_vec_ruld = bsxfun(@eq, theta_vec, pi/4);
theta_vec_ud = bsxfun(@eq, theta_vec, pi/2);
theta_vec_lurd = bsxfun(@eq, theta_vec, 3*pi/4);

J_high = J_high(:);
J_low = J_low(:);

J_low_lr1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_up)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_down)));
J_low_lr2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_ru)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_ld)));
J_low_lr3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_lu)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_rd)));
J_low_lr = bsxfun(@or, bsxfun(@or, J_low_lr1, J_low_lr2), J_low_lr3);
J_low_ruld1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_lu)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_rd)));
J_low_ruld2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_left)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_right)));
J_low_ruld3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_up)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_down)));
J_low_ruld = bsxfun(@or, bsxfun(@or, J_low_ruld1, J_low_ruld2), J_low_ruld3);
J_low_ud1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_left)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_right)));
J_low_ud2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_ld)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_ru)));
J_low_ud3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_rd)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_lu)));
J_low_ud = bsxfun(@or, bsxfun(@or, J_low_ud1, J_low_ud2), J_low_ud3);
J_low_lurd1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_ld)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_ru)));
J_low_lurd2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_down)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_up)));
J_low_lurd3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_left)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_right)));
J_low_lurd = bsxfun(@or, bsxfun(@or, J_low_lurd1, J_low_lurd2), J_low_lurd3);
J_low_valid = bsxfun(@or, bsxfun(@or, J_low_lr, J_low_ruld), bsxfun(@or, J_low_ud, J_low_lurd));
J_high_new = bitor(J_high, J_low_valid);

while sum(bitxor(J_high_new, J_high)) ~= 0;
    J_high = J_high_new;
    J_low_lr1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_up)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_down)));
    J_low_lr2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_ru)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_ld)));
    J_low_lr3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_lu)), bsxfun(@and, J_low.*theta_vec_lr, J_high(ind_rd)));
    J_low_lr = bsxfun(@or, bsxfun(@or, J_low_lr1, J_low_lr2), J_low_lr3);
    J_low_ruld1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_lu)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_rd)));
    J_low_ruld2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_left)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_right)));
    J_low_ruld3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_up)), bsxfun(@and, J_low.*theta_vec_ruld, J_high(ind_down)));
    J_low_ruld = bsxfun(@or, bsxfun(@or, J_low_ruld1, J_low_ruld2), J_low_ruld3);
    J_low_ud1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_left)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_right)));
    J_low_ud2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_ld)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_ru)));
    J_low_ud3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_rd)), bsxfun(@and, J_low.*theta_vec_ud, J_high(ind_lu)));
    J_low_ud = bsxfun(@or, bsxfun(@or, J_low_ud1, J_low_ud2), J_low_ud3);
    J_low_lurd1 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_ld)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_ru)));
    J_low_lurd2 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_down)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_up)));
    J_low_lurd3 = bsxfun(@or, bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_left)), bsxfun(@and, J_low.*theta_vec_lurd, J_high(ind_right)));
    J_low_lurd = bsxfun(@or, bsxfun(@or, J_low_lurd1, J_low_lurd2), J_low_lurd3);
    J_low_valid = bsxfun(@or, bsxfun(@or, J_low_lr, J_low_ruld), bsxfun(@or, J_low_ud, J_low_lurd));
    J_high_new = bitor(J_high, J_low_valid);
end

E = J_high_new;

E = reshape(E, [nr, nc]);

end
