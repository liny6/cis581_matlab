function morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac...
    ,dissolve_frac)
    

    %% Compute intermediate control points
    im_points = (1-warp_frac).*im1_pts + warp_frac.*im2_pts;
    
    %% compute tps coeff
    %for im1
    % coeff for x
    [a1_x1,ax_x1,ay_x1,w_x1] = est_tps(im_points, im1_pts(:,1));
    %coef for y
    [a1_y1,ax_y1,ay_y1,w_y1] = est_tps(im_points, im1_pts(:,2));
    %for im2
    [a1_x2,ax_x2,ay_x2,w_x2] = est_tps(im_points, im2_pts(:,1));
    [a1_y2,ax_y2,ay_y2,w_y2] = est_tps(im_points, im2_pts(:,2));
    
    %% imverse warping
    % from im1
    morphed_im1 = morph_tps(im1, a1_x1, ax_x1, ay_x1, w_x1, a1_y1, ax_y1, ay_y1, w_y1, im_points, [size(im1,1),size(im1,2)]);
    
    % from im2
    morphed_im2 = morph_tps(im2, a1_x2, ax_x2, ay_x2, w_x2, a1_y2, ax_y2, ay_y2, w_y2, im_points, [size(im1,1),size(im1,2)]);

    
    %% blend
    morphed_im = (1-dissolve_frac).*morphed_im1 + dissolve_frac.*morphed_im2;
    morphed_im = uint8(morphed_im);
end
