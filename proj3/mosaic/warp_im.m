function [I_warped, x_shift, y_shift] = warp_im(I, H)
%WARP Summary of this function goes here
%   Detailed explanation goes here

[nr, nc, ~] = size(I);

corners = [1, 1, nc, nc;
           1, nr, 1, nr];
       
[x_warp, y_warp] = apply_homography(H, corners(1, :)', corners(2, :)');

x_shift = min(x_warp);
y_shift = min(y_warp);

nc_new = max(x_warp) - min(x_warp);
nr_new = max(y_warp) - min(y_warp);

[y_print, x_print] = meshgrid(1:nr_new, 1:nc_new);

[x_backward, y_backward] = apply_homography(inv(H), (x_print(:)+x_shift), (y_print(:)+y_shift));

x_backward = round(x_backward);
y_backward = round(y_backward);

ind_avail = bitand(bitand(x_backward>1, x_backward<=nc),bitand(y_backward>1, y_backward<=nr));

x_backward = x_backward(ind_avail);
y_backward = y_backward(ind_avail);


x_print = x_print(ind_avail);
y_print = y_print(ind_avail);

nr_new = max(y_print);
nc_new = max(x_print);

ind_print = sub2ind([nr_new, nc_new], y_print, x_print);
ind_backward = sub2ind([nr, nc], y_backward, x_backward);

Ir = I(:, :, 1);
Ig = I(:, :, 2);
Ib = I(:, :, 3);

I_warped_r = zeros(nr_new*nc_new, 1);
I_warped_g = zeros(nr_new*nc_new, 1);
I_warped_b = zeros(nr_new*nc_new, 1);

I_warped_r(ind_print) = Ir(ind_backward);
I_warped_g(ind_print) = Ig(ind_backward);
I_warped_b(ind_print) = Ib(ind_backward);

I_warped = zeros(nr_new, nc_new, 3);

I_warped(:, :, 1) = reshape(I_warped_r, [nr_new, nc_new]);
I_warped(:, :, 2) = reshape(I_warped_g', [nr_new, nc_new]);
I_warped(:, :, 3) = reshape(I_warped_b', [nr_new, nc_new]);

end

