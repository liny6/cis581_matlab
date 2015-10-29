function [ H, inlier_ind ] = ransac_est_homography( y1, x1, y2, x2, thresh )
%RANSAC Summary of this function goes here
%   Detailed explanation goes here

l = length(y1); %find number of features to match
some_ind = 1:l;
inlier_count_old = 0;

for i = 1:4000
    
    rand_inds = ceil(rand(1, 4)*l);
    y1_fit = y1(rand_inds);
    x1_fit = x1(rand_inds);
    y2_fit = y2(rand_inds);
    x2_fit = x2(rand_inds);
    
    H_guess = est_homography(x1_fit, y1_fit, x2_fit, y2_fit);
    [x1_h, y1_h] = apply_homography(H_guess, x2, y2);
    
    dist = sqrt((x1 - x1_h).^2 + (y1 - y1_h).^2);
    
    inliers = (dist<thresh);
    inlier_count = sum(inliers);
    
    if inlier_count > inlier_count_old
        inlier_ind = some_ind(inliers);
        H = H_guess;
        inlier_count_old = inlier_count;
    end
end



end

