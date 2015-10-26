function morphed_im = morph_tps(im_src, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)

[nr_src, nc_src, ~] = size(im_src);
nr = sz(1);
nc = sz(2);

morphed_im = zeros(nr, nc, 3);
%{
x_old = (1:nc);
y_old = (1:nr);
rv = (bsxfun(@minus, ctr_pts(:,1)' ,x_old').^2 + bsxfun(@minus, ctr_pts(:,2)', y_old').^2);
%r = (bsxfun(@minus, ctr_pts(:,1)' ,ctr_pts(:,1)).^2 + bsxfun(@minus, ctr_pts(:,2)', ctr_pts(:,2)).^2);
%Ud = -rd.*log(rd);
Uv = -rv.*log(rv);
Uv(isnan(Uv)) = 0;


%x_newd = a1_x + ax_x*ctr_pts(:,1) + ay_x*ctr_pts(:,2) + sum(bsxfun(@times, w_x', Ud),2);
%y_newd = a1_y + ax_y*ctr_pts(:,1) + ay_y*ctr_pts(:,2) + sum(bsxfun(@times, w_y', Ud),2);
x_newv = a1_x + ax_x*x_old' + ay_x*y_old' + sum(bsxfun(@times, w_x', Uv),2);
y_newv = a1_y + ax_y*x_old' + ay_y*y_old' + sum(bsxfun(@times, w_y', Uv),2);
%clamp values that are outside of the image
x_newv(x_newv < 1) = 1;
y_newv(y_newv < 1) = 1;

x_newv(x_newv > nc) = nc;
y_newv(y_newv > nr) = nr;

x_low = floor(x_newv);
x_high = ceil(x_newv);
y_low = floor(y_newv);
y_high = ceil(y_newv);

%bilinear interpolation

%morphed_im_yhigh = bsxfun(@times, double(im_src(y_low, x_high, :)), (y_high - y_new)) + bsxfun(@times, double(im_src(y_high, x_high, :)), (y_new - y_low));
%morphed_im_ylow = bsxfun(@times, double(im_src(y_low, x_low, :)), (y_high - y_new)) + bsxfun(@times, double(im_src(y_high, x_low, :)), (y_new - y_low));
%morphed_im = bsxfun(@times, morphed_im_yhigh, (x_new - x_low)') + bsxfun(@times, morphed_im_ylow, (x_high - x_new)');

morphed_im = im_src(y_low, x_low, :);
%}
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