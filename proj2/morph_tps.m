function morphed_im = morph_tps(im_src, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)

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
        for k = 1:3
            r = (ctr_pts(:,1)-i).^2 + (ctr_pts(:,2)-j).^2;
            U = -r.*log(r);
            x_new = a1_x + ax_x*i + ay_x*j + sum(w_x.*U);
            y_new = a1_y + ax_y*i + ay_y*j + sum(w_y.*U);
            if x_new < 1
                x_new = 1;
            end
            
            if y_new < 1
                y_new =1;
            end
            
            if x_new > nc
                x_new = nc;
            end
            
            if y_new > nr
                y_new = nr;
            end
              morphed_im(j, i, k) = im_src(round(y_new), round(x_new), k);
        end
    end
end
end