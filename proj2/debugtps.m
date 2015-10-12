load 'correspondence.mat'
figure(1)
imshow(uint8(im_src))
hold on
plot(im1_pts(:,1), im1_pts(:,2), 'bx')
figure(2)
imshow(uint8(morphed_im));
hold on
plot(ctr_pts(:,1), ctr_pts(:,2), 'rx')

rd = (bsxfun(@minus, ctr_pts(:,1)' ,ctr_pts(:,1)).^2 + bsxfun(@minus, ctr_pts(:,2)', ctr_pts(:,2)).^2);
Ud = -rd.*log(rd);
Ud(isnan(Ud)) = 0;
x_newd = a1_x + ax_x*ctr_pts(:,1) + ay_x*ctr_pts(:,2) + sum(bsxfun(@times, w_x', Ud),2);
y_newd = a1_y + ax_y*ctr_pts(:,1) + ay_y*ctr_pts(:,2) + sum(bsxfun(@times, w_y', Ud),2);

pos =59;

x = round(x_newd(pos))
y = round(y_newd(pos))

im_src(x,y,:)