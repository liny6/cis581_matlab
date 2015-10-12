function tri  = GetTri(im1_pts, im2_pts)
%GETMEANPOS Summary of this function goes here
%   Detailed explanation goes here
mean_pts = im1_pts * 0.5 + im2_pts * 0.5;
tri = delaunay(mean_pts(:, 1), mean_pts(:, 2));
end

