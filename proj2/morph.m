function morphed_im = morph( im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac )
%MORPH Summary of this function goes here
%   Detailed explanation goes here
[nr, nc, nrgb] = size(im1);
mean_pts = im1_pts * warp_frac + im2_pts * (1 - warp_frac);

im1_mid = zeros(nr, nc, nrgb);
im2_mid = zeros(nr, nc, nrgb);

for i = 1:nc
    for j = 1:nr
        for k = 1:nrgb
            %determine which triangle the pixel falls in
            tri_ind =  tsearchn(mean_pts, tri, [i,j]);
            if (isnan(tri_ind))
                im1_mid(i, j, k) = 0;
                im2_mid(i, j, k) = 0;
            else
                a = mean_pts(tri(tri_ind, 1), :);
                b = mean_pts(tri(tri_ind, 2), :);
                c = mean_pts(tri(tri_ind, 3), :);
                bary_mat_mean = [a', b', c';
                    1 , 1 , 1 ];
                bary_coord_mean = bary_mat_mean \ [i; j; 1];
                
                %calculate the pixel coordinate in image 1
                a1 = im1_pts(tri(tri_ind, 1), :);
                b1 = im1_pts(tri(tri_ind, 2), :);
                c1 = im1_pts(tri(tri_ind, 3), :);
                
                bary_mat_1 = [a1', b1', c1';
                    1  , 1  , 1  ];
                
                pixel_coord_1 = bary_mat_1 * bary_coord_mean;
                x1 = pixel_coord_1(2);
                x1_low = floor(x1);
                x1_high = ceil(x1);
                y1 = pixel_coord_1(1);
                y1_low = floor(y1);
                y1_high = ceil(y1);
                
                %calculate the pixel coordinate in image 2
                a2 = im2_pts(tri(tri_ind, 1), :);
                b2 = im2_pts(tri(tri_ind, 2), :);
                c2 = im2_pts(tri(tri_ind, 3), :);
                
                bary_mat_2 = [a2', b2', c2';
                    1  , 1  , 1  ];
                
                pixel_coord_2 = bary_mat_2 * bary_coord_mean;
                x2 = pixel_coord_2(2);
                x2_low = floor(x2);
                x2_high = ceil(x2);
                y2 = pixel_coord_2(1);
                y2_low = floor(y2);
                y2_high = ceil(y2);
                % inverse warping, fill in intermediate image with the source image
                %bilinear interpolation
                avgy1low = im1(x1_low, y1_low, k) * (x1_high - x1) + im1(x1_high, y1_low, k) * (x1 - x1_low);
                avgy1high = im1(x1_low, y1_high, k) * (x1_high - x1) + im1(x1_high, y1_high, k) * (x1 - x1_low);
                
                im1_mid(j, i, k) =  (avgy1low * (y1_high - y1) + avgy1high* (y1-y1_low));
                
                avgy2low = im2(x2_low, y2_low, k) * (x2_high - x2) + im2(x2_high, y2_low, k) * (x2 - x2_low);
                avgy2high = im2(x2_low, y2_high, k) * (x2_high - x2) + im2(x2_high, y2_high, k) * (x2 - x2_low);
                
                im2_mid(j, i, k) =  (avgy2low * (y2_high - y2) + avgy2high* (y2-y2_low));
            end
        end
    end
end
morphed_im = uint8(im1_mid*dissolve_frac + im2_mid*(1-dissolve_frac));

end

