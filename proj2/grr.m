close all
warp_frac = 0.5;
[nr, nc, nrgb] = size(im1);

mean_pts = im1_pts * warp_frac + im2_pts * (1 - warp_frac);

[a1X1, axX1, ayX1, wX1] = est_tps(mean_pts, im1_pts(:,1));
[a1Y1, axY1, ayY1, wY1] = est_tps(mean_pts, im1_pts(:,2));
[a1X2, axX2, ayX2, wX2] = est_tps(mean_pts, im2_pts(:,1));
[a1Y2, axY2, ayY2, wY2] = est_tps(mean_pts, im2_pts(:,2));

morphed1 = morph_tps(im1, a1X1, axX1, ayX1, wX1, a1Y1, axY1, ayY1, wY1, mean_pts, [300, 300]);
morphed2 = morph_tps(im2, a1X2, axX2, ayX2, wX2, a1Y2, axY2, ayY2, wY2, mean_pts, [300, 300]);

morphed_final = 0.5*morphed1 + (1-0.5)*morphed2;


figure(1)
imshow(uint8(morphed1))
figure(2)
imshow(uint8(morphed2))
figure(3)
imshow(uint8(morphed_final))