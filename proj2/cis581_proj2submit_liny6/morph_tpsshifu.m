function morphed_im = morph_tps(im_src, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)

[nr_src, nc_src, ~] = size(im_src);
nr = sz(1);
nc = sz(2);

morphed_im = zeros(nr, nc, 3);

for i = 1:nc
    for j = 1:nr
            
            x_old = i*nc_src/nc;
            y_old = j*nr_src/nr;
            
            r = (ctr_pts(:,1)-x_old).^2 + (ctr_pts(:,2)-y_old).^2;
            U = -r.*log(r);
            U(isnan(U)) = 0;
            x_new = a1_x + ax_x*x_old + ay_x*y_old + sum(w_x.*U);
            y_new = a1_y + ax_y*x_old + ay_y*y_old + sum(w_y.*U);
         
            %bilinear interpolation
            if x_new < 1
                x_new = 1;
            end
            
            if y_new < 1
                y_new =1;
            end
            
            if x_new > nc_src
                x_new = nc_src;
            end

            if y_new > nr_src
                y_new = nr_src;
            end
 
            x_high = ceil(x_new);
            x_low = floor(x_new);
            
            y_high = ceil(y_new);
            y_low = floor(y_new);
            
            if x_high ~= x_new
                avgyhigh = im_src(y_high, x_low, :) * (x_high - x_new) + im_src(y_high, x_high, :) * (x_new - x_low);
                avgylow = im_src(y_low, x_low, :) * (x_high - x_new) + im_src(y_low, x_high, :) * (x_new - x_low);
            else
                avgyhigh = im_src(y_high, x_new, :);
                avgylow = im_src(y_low, x_new, :);
            end
            
            if y_high ~= y_new
                morphed_im(j, i, :) = avgyhigh*(y_new - y_low) + avgylow*(y_high - y_new);
            else
                morphed_im(j, i, :) = avgylow;
            end
            
            
    end
end
end