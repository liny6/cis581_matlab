function morphed_im = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)

[x,y] = meshgrid(1:size(im_source,2),1:size(im_source,1));
x_ind = x(:);
y_ind = y(:);
ind_Br = sub2ind(size(im_source), y_ind, x_ind,ones(size(x_ind,1),1));
ind_Bg = sub2ind(size(im_source), y_ind, x_ind,2*ones(size(x_ind,1),1));
ind_Bb = sub2ind(size(im_source), y_ind, x_ind,3*ones(size(x_ind,1),1));

r_sq = (repmat(ctr_pts(:,1)',size(x_ind,1),1) - repmat(x_ind,1,size(ctr_pts,1))).^2 ...
    + (repmat(ctr_pts(:,2)',size(y_ind,1),1) - repmat(y_ind,1,size(ctr_pts,1))).^2;
U = r_sq.*log(r_sq);
U(isnan(U)) = 0;

im_xy = repmat([a1_x,a1_y],size(x_ind,1),1) + repmat([ax_x,ax_y],size(x_ind,1),1).* [x_ind,x_ind] ...
    + repmat([ay_x,ay_y],size(y_ind,1),1).* [y_ind, y_ind] +  U*[w_x,w_y] ;
im_xy = round(im_xy);


im_xy(im_xy(:,1)>size(im_source,2),1) = size(im_source,2);
im_xy(im_xy(:,2)>size(im_source,1),2) = size(im_source,1);
im_xy(im_xy<1) =1;

ind_Ar = sub2ind(size(im_source),im_xy(:,2),im_xy(:,1),ones(size(im_xy,1),1));
ind_Ag = sub2ind(size(im_source),im_xy(:,2),im_xy(:,1),2*ones(size(im_xy,1),1));
ind_Ab = sub2ind(size(im_source),im_xy(:,2),im_xy(:,1),3*ones(size(im_xy,1),1));

morphed_im = zeros(size(im_source));
morphed_im(ind_Br) = im_source(ind_Ar);
morphed_im(ind_Bg) = im_source(ind_Ag);
morphed_im(ind_Bb) = im_source(ind_Ab);

morphed_im = uint8(morphed_im);
morphed_im = imresize(morphed_im, sz);
end