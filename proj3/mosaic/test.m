I1 = imread('v1.jpg');
I2 = imread('v3.jpg');

[nr1, nc1, ~] = size(I1);

I1_process = double(rgb2gray(I1));
I2_process = double(rgb2gray(I2));

R1 = FindCornerMap(I1_process);
R2 = FindCornerMap(I2_process);


[y1, x1, rmax1] = anms(R1, 150);
[y2, x2, rmax2] = anms(R2, 150);

I12 = [rgb2gray(I1), rgb2gray(I2)];


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
matching_line = plot([0, 0], [0, 0]);
%{
%debugging code thingy
for i = 1:length(mp)
    num = sprintf('%d', i);
    ind1 = mp(i, 1);
    ind2 = mp(i, 2);
    figure(3)
    imagesc(reshape(p1(:, ind1),[8, 8]))
    figure(4)
    imagesc(reshape(p2(:, ind2),[8, 8]))
    set(matching_line, 'xdata', [x1(ind1), nc1+x2(ind2)], 'ydata', [y1(ind1), y2(ind2)])
end
%}
x1_clean = x1(mp(:,1));
y1_clean = y1(mp(:,1));

x2_clean = x2(mp(:,2));
y2_clean = y2(mp(:,2));

[H, inlier_ind] = ransac_est_homography(y1_clean, x1_clean, y2_clean, x2_clean, 10);

for i = 1 : length(inlier_ind)
    plot([x1_clean(inlier_ind(i)), x2_clean(inlier_ind(i))+nc1],[y1_clean(inlier_ind(i)), y2_clean(inlier_ind(i))])
end
%{
I_stitched = stitch(I1, I2, H);
figure
imshow(I_stitched);
%}
%I_warped = warp(I2, H);