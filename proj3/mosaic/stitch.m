function I_stitched = stitch( I1, I2, H )
%STITCH 2 images given homography

%% First Figure out how big the final image should be
[nr1, nc1, ~] = size(I1);
[nr2, nc2, ~] = size(I2);

corners = [1, 1, nc2, nc2;
           1, nr2, 1, nr2];
       
[x_warp, y_warp] = apply_homography(H, corners(1, :)', corners(2, :)');

%corners_I2 = [x_warp'; y_warp'];

x_shift = min(x_warp);
y_shift = min(y_warp);

%corners_I2(1, :) = ceil(corners_I2(1,:) - floor(x_shift));
%corners_I2(2, :) = ceil(corners_I2(2,:) - floor(y_shift));


if x_shift < 0
    nc_new = ceil(max([max(x_warp) - x_shift, nc1 - x_shift]));
else
    nc_new = ceil(max([max(x_warp), nc1]));
end

if y_shift < 0
    nr_new = ceil(max([max(y_warp) - y_shift, nc1 - y_shift]));
else
    nr_new = ceil(max([max(y_warp), nr1]));
end

%% Warp + move I2

[y_print, x_print] = meshgrid(1:nr_new, 1:nc_new);

[x_backward, y_backward] = apply_homography(inv(H), (x_print(:)+x_shift), (y_print(:)+y_shift));

%x_backward = round(x_backward);
%y_backward = round(y_backward);

x_backward_xlow = floor(x_backward);
x_backward_xhigh = ceil(x_backward);

y_backward_ylow = floor(y_backward);
y_backward_yhigh = ceil(y_backward);

x_dist = x_backward - x_backward_xlow;
y_dist = y_backward - y_backward_ylow;

ind_avail = bitand(bitand(x_backward>1, x_backward<=nc2),bitand(y_backward>1, y_backward<=nr2));

x_backward_xlow = x_backward_xlow(ind_avail);
y_backward_ylow = y_backward_ylow(ind_avail);

x_backward_xhigh = x_backward_xhigh(ind_avail);
y_backward_yhigh = y_backward_yhigh(ind_avail);

x_print = x_print(ind_avail);
y_print = y_print(ind_avail);
x_dist = x_dist(ind_avail);
y_dist = y_dist(ind_avail);

if x_shift > 0
    x_print = x_print + floor(x_shift);
%    corners_I2(1, :) = (corners_I2(1,:) + floor(x_shift));
end

if y_shift > 0
    y_print = y_print + floor(y_shift);
%    corners_I2(2, :) = (corners_I2(2,:) + floor(y_shift));
end

x_print(x_print>nc_new) = nc_new;
y_print(y_print>nr_new) = nr_new;

ind_print = sub2ind([nr_new, nc_new], y_print, x_print);
ind_ylowxlow = sub2ind([nr2, nc2], y_backward_ylow, x_backward_xlow);
ind_ylowxhigh = sub2ind([nr2, nc2], y_backward_ylow, x_backward_xhigh);
ind_yhighxlow = sub2ind([nr2, nc2], y_backward_yhigh, x_backward_xlow);
ind_yhighxhigh = sub2ind([nr2, nc2], y_backward_yhigh, x_backward_xhigh);

% all these for anti aliasing
% the word i am looking for is bilinear interpolation

I2r = double(I2(:, :, 1));
I2g = double(I2(:, :, 2));
I2b = double(I2(:, :, 3));

I2_warped_r_ylow = zeros(nr_new*nc_new, 1);
I2_warped_g_ylow = zeros(nr_new*nc_new, 1);
I2_warped_b_ylow = zeros(nr_new*nc_new, 1);

I2_warped_r_yhigh = zeros(nr_new*nc_new, 1);
I2_warped_g_yhigh= zeros(nr_new*nc_new, 1);
I2_warped_b_yhigh= zeros(nr_new*nc_new, 1);

I2_warped_r = zeros(nr_new*nc_new, 1);
I2_warped_g = zeros(nr_new*nc_new, 1);
I2_warped_b = zeros(nr_new*nc_new, 1);

I2_warped_r_ylow(ind_print) = I2r(ind_ylowxlow).*(1-x_dist(:)) + I2r(ind_ylowxhigh).*x_dist(:);
I2_warped_g_ylow(ind_print) = I2g(ind_ylowxlow).*(1-x_dist(:)) + I2g(ind_ylowxhigh).*x_dist(:);
I2_warped_b_ylow(ind_print) = I2b(ind_ylowxlow).*(1-x_dist(:)) + I2b(ind_ylowxhigh).*x_dist(:);

I2_warped_r_yhigh(ind_print) = I2r(ind_yhighxlow).*(1-x_dist(:)) + I2r(ind_yhighxhigh).*x_dist(:);
I2_warped_g_yhigh(ind_print) = I2g(ind_yhighxlow).*(1-x_dist(:)) + I2g(ind_yhighxhigh).*x_dist(:);
I2_warped_b_yhigh(ind_print) = I2b(ind_yhighxlow).*(1-x_dist(:)) + I2b(ind_yhighxhigh).*x_dist(:);

I2_warped_r(ind_print) = I2_warped_r_ylow(ind_print).*(1-y_dist(:)) + I2_warped_r_yhigh(ind_print).*y_dist(:);
I2_warped_g(ind_print) = I2_warped_g_ylow(ind_print).*(1-y_dist(:)) + I2_warped_g_yhigh(ind_print).*y_dist(:);
I2_warped_b(ind_print) = I2_warped_b_ylow(ind_print).*(1-y_dist(:)) + I2_warped_b_yhigh(ind_print).*y_dist(:);

I2_warped = zeros(nr_new, nc_new, 3);

I2_warped(:, :, 1) = reshape(I2_warped_r', [nr_new, nc_new]);
I2_warped(:, :, 2) = reshape(I2_warped_g', [nr_new, nc_new]);
I2_warped(:, :, 3) = reshape(I2_warped_b', [nr_new, nc_new]);

%% shift I1

%there are two different cases, if shift for I2 is negative, move I1, If
%it's postive, don't move

%corners_I1 = [1, 1, nc1, nc1;
 %             1, nr1, 1, nr1];

if x_shift < 0
    x1 = ceil(-x_shift):(nc1-ceil(x_shift));
%    corners_I1(1,:) = corners_I1(1,:) - floor(x_shift);
else 
    x1 = 1:nc1;
end

if y_shift < 0
    y1 = ceil(-y_shift):(nr1-ceil(y_shift));
%    corners_I1(2,:) = corners_I1(2,:) - floor(y_shift);
else
    y1 = 1:nr1;
end


[y1_new, x1_new, color_new] = meshgrid(y1, x1, 1:3);
[y1_old, x1_old, color_old] = meshgrid(1:nr1, 1:nc1, 1:3);

ind_I1 = sub2ind([nr1, nc1, 3], y1_old, x1_old, color_old);
ind_I1_new = sub2ind([nr_new, nc_new, 3], y1_new, x1_new, color_new);

I1_shifted = zeros(nr_new, nc_new, 3);

I1_shifted(ind_I1_new) = I1(ind_I1);


%% find intersection region

Isx = bsxfun(@and, sum(I1_shifted,3), sum(I2_warped,3));
%intersection
I1_mask = ~bsxfun(@and, sum(I1_shifted, 3), 1);
I2_mask = ~bsxfun(@and, sum(I2_warped, 3), 1);

I1_mask = bwdist(I1_mask);
I2_mask = bwdist(I2_mask);

alpha = I1_mask./(I1_mask+I2_mask);
%condition away Nan
alpha(isnan(alpha)) = 0;

I1_blend = bsxfun(@times, I1_shifted, alpha);
I2_blend = bsxfun(@times, I2_warped, 1-alpha);

I_stitched = uint8(I1_blend + I2_blend);
%I1_mask = I1_mask - Isx;
%I2_mask = I2_mask - Isx;

%I1_blend = bsxfun(@times, I1_shifted, I1_mask);
%I2_blend = bsxfun(@times, I2_warped, I2_mask);

%I_stitched = uint8(I1_blend+I2_blend);

end

