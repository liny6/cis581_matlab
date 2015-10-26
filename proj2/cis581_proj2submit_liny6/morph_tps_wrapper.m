function morphed_im = morph_tps_wrapper( im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
%MORPH_TPS_WRAPPER Summary of this function goes here
%   Detailed explanation goes here
[nr, nc, ~] = size(im1);

mean_pts = im1_pts * (1-warp_frac) + im2_pts * (warp_frac);

[a1X1, axX1, ayX1, wX1] = est_tps(mean_pts, im1_pts(:,1));
[a1Y1, axY1, ayY1, wY1] = est_tps(mean_pts, im1_pts(:,2));
[a1X2, axX2, ayX2, wX2] = est_tps(mean_pts, im2_pts(:,1));
[a1Y2, axY2, ayY2, wY2] = est_tps(mean_pts, im2_pts(:,2));

morphed_im1 = morph_tps(im1, a1X1, axX1, ayX1, wX1, a1Y1, axY1, ayY1, wY1, mean_pts, [nr, nc]);
morphed_im2 = morph_tps(im2, a1X2, axX2, ayX2, wX2, a1Y2, axY2, ayY2, wY2, mean_pts, [nr, nc]);
%{
figure(1)
imshow(uint8(morphed_im1))
figure(2)
imshow(uint8(morphed_im2))
figure(3)
%}
morphed_im = uint8(morphed_im1*(1-dissolve_frac) + morphed_im2*(dissolve_frac));
%imshow(morphed_im)

end

