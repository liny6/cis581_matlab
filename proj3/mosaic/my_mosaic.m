function I_stitched = my_mosaic( I1, I2 )

[nr1, nc1, ~] = size(I1);
[nr2, nc2, ~] = size(I2);


I1_process = double(rgb2gray(I1));
I2_process = double(rgb2gray(I2));

R1 = FindCornerMap(I1_process);
R2 = FindCornerMap(I2_process);

nr_plot = max([nr1, nr2]);
nc_plot = max([nc1, nc2]);

I1plot = zeros(nr_plot, nc_plot, 3);
I2plot = zeros(nr_plot, nc_plot, 3);

[r1, c1, rgb1] = meshgrid(1:nr1, 1:nc1, 1:3);
[r2, c2, rgb2] = meshgrid(1:nr2, 1:nc2, 1:3);


I1_plot_ind = sub2ind([nr_plot, nc_plot, 3], r1, c1, rgb1);
I2_plot_ind = sub2ind([nr_plot, nc_plot, 3], r2, c2, rgb2);
I1_ind = sub2ind([nr1, nc1, 3],r1, c1, rgb1);
I2_ind = sub2ind([nr2, nc2, 3],r2, c2, rgb2);

I1plot(I1_plot_ind) = I1(I1_ind);
I2plot(I2_plot_ind) = I2(I2_ind);


[y1, x1, ~] = anms(R1, 150);
[y2, x2, ~] = anms(R2, 150);

I12 = uint8([I1plot, I2plot]);


figure(1)
imshow(I12)
hold on
plot(x1, y1, 'ro')
plot(x2+nc1, y2, 'ro')

p1 = feat_desc(I1_process, y1, x1);
p2 = feat_desc(I2_process, y2, x2);

m = feat_match(p1, p2);

m_valid = m~=-1;

mp = [(1:length(m))', m];

mp = mp(m_valid, :);
figure(1)

x1_clean = x1(mp(:,1));
y1_clean = y1(mp(:,1));

x2_clean = x2(mp(:,2));
y2_clean = y2(mp(:,2));

[H, inlier_ind] = ransac_est_homography(y1_clean, x1_clean, y2_clean, x2_clean, 10);

for i = 1 : length(inlier_ind)
    plot([x1_clean(inlier_ind(i)), x2_clean(inlier_ind(i))+nc1],[y1_clean(inlier_ind(i)), y2_clean(inlier_ind(i))])
end

I_stitched = stitch(I1, I2, H);
figure
imshow(I_stitched);


end

