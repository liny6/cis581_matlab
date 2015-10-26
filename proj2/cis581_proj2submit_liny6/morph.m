function morphed_im = morph( im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac )
%MORPH Summary of this function goes here
%   Detailed explanation goes here
[nr, nc, nrgb] = size(im1);
mean_pts = im1_pts * (1-warp_frac) + im2_pts * (warp_frac);

im1_mid = zeros(nr, nc, nrgb);
im2_mid = zeros(nr, nc, nrgb);

for i = 1:nc
    for j = 1:nr
        %determine which triangle the pixel falls in
        tri_ind =  tsearchn(mean_pts, tri, [i,j]);
        if (isnan(tri_ind))
            im1_mid(j, i, :) = [0, 0, 0];
            im2_mid(j, i, :) = [0, 0, 0];
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
            if x1 < 1
                x1 = 1;
            end
            
            if x1 > nc
                x1 = nc;
            end
            
            x1_low = floor(x1);
            x1_high = ceil(x1);
            y1 = pixel_coord_1(1);
            
            if y1 < 1
                y1 = 1;
            end
            
            if y1 > nr
                y1 = nr;
            end
            
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
            if x2 < 1
                x2 = 1;
            end
            
            if x2 > nc
                x2 = nc;
            end
            x2_low = floor(x2);
            x2_high = ceil(x2);
            y2 = pixel_coord_2(1);
            if y2 < 1
                y2 = 1;
            end
            
            if y2 > nr
                y2 = nr;
            end
            y2_low = floor(y2);
            y2_high = ceil(y2);
            % inverse warping, fill in intermediate image with the source image
            %bilinear interpolation
            
            if x1_high ~= x1
                
                avgy1low = im1(x1_low, y1_low, :) * (x1_high - x1) + im1(x1_high, y1_low, :) * (x1 - x1_low);
                avgy1high = im1(x1_low, y1_high, :) * (x1_high - x1) + im1(x1_high, y1_high, :) * (x1 - x1_low);
            else
                avgy1low = im1(x1, y1_low, :);
                avgy1high = im1(x1, y1_high, :);
            end
            
            if y1_high ~= y1
                im1_mid(j, i, :) =  (avgy1low * (y1_high - y1) + avgy1high* (y1-y1_low));
            else
                im1_mid(j, i, :) = avgy1low;
            end
            
            if x2_high ~= x2
                avgy2low = im2(x2_low, y2_low, :) * (x2_high - x2) + im2(x2_high, y2_low, :) * (x2 - x2_low);
                avgy2high = im2(x2_low, y2_high, :) * (x2_high - x2) + im2(x2_high, y2_high, :) * (x2 - x2_low);
            else
                avgy2low = im2(x2, y2_low, :);
                avgy2high = im2(x2, y2_high, :);
            end
            
            if y2_high ~= y2
                im2_mid(j, i, :) =  (avgy2low * (y2_high - y2) + avgy2high* (y2-y2_low));
            else
                im2_mid(j, i, :) = avgy2low;
            end
            
        end
    end
end
morphed_im = uint8(im1_mid*(1 - dissolve_frac) + im2_mid*(dissolve_frac));

end

