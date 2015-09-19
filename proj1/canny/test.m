I = imread('BSR/BSDS500/data/images/train/100080.jpg');
figure(1)
I = rgb2gray(I);

imagesc(I)

Gx = normpdf([-5:1:5], 0, 1);
Gy = normpdf([-5:1:5], 0, 1)';

[J , theta, Jx, Jy] = findDerivatives(I,Gx,Gy);

hold on

axis image
quiver(Jx, Jy)

[nr, nc] = size(I);
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

original = sub2ind([nr, nc], y(:), x(:));
 
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






M = reshape(edge, [nr, nc]);

%=================================%
J_sup = J.* M;
[nr, nc] = size(J);

high = 20;
low = 4;

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

J_high = J_high(:);
J_low = J_low(:);

J_low_lr = bsxfun(@or, bsxfun(@and, J_low, J_high(ind_right)), bsxfun(@and, J_low, J_high(ind_left)));
J_low_ruld = bsxfun(@or, bsxfun(@and, J_low, J_high(ind_ru)), bsxfun(@and, J_low, J_high(ind_ld)));
J_low_ud = bsxfun(@or, bsxfun(@and, J_low, J_high(ind_up)), bsxfun(@and, J_low, J_high(ind_down)));
J_low_lurd = bsxfun(@or, bsxfun(@and, J_low, J_high(ind_lu)), bsxfun(@and, J_low, J_high(ind_rd)));

J_low_valid = bsxfun(@or, bsxfun(@or, J_low_lr, J_low_ruld), bsxfun(@or, J_low_ud, J_low_lurd));

E = J_high + J_low;

E = reshape(E, [nr, nc]);

%{
J_g1 = zeros(ydim, xdim);
J_g2 = zeros(ydim, xdim);

for i = 1:xdim
    for j = 1:ydim
        J_g1 = (1-J_x_nrlzd (i, j))*J(i,j) + J_x_nrlzd(i, j)*J(i+1,j) +...
            (1-J_y_nrlzd(i, j))*J(i,j) + J_y_nrlzd(i, j)*J(i, j+1); %please vectorize this
    end
end
%}