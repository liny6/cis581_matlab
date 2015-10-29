function p = ExtractDes(I, y, x)
%extract feature descriptor
%let's get a 8x8 patch describing each corner
%p is a 64xn matrix

%first we start at each corner location and take a 40x 40 window
window_size = 40;
p_size = 8;
sub = window_size/p_size;
num_corner = length(y);
p = zeros(p_size^2, num_corner);

%gaussian kernel for blurring, 9x9 here
Gaus = normpdf(-3:1:3, 0, 1);
Gaus = conv2(Gaus, Gaus');
%{
left_ind = 0;
right_ind = 0;
up_ind = 0;
down_ind = 0;
    
    figure(3)
    imshow(uint8(I));
    figure(3)
    hold on
    l1=plot([left_ind, right_ind], [up_ind, up_ind]);
    l2=plot([left_ind, right_ind], [down_ind, down_ind]);
    l3=plot([right_ind, right_ind], [up_ind, down_ind]);
    l4=plot([left_ind, left_ind], [up_ind, down_ind]);
    cnr = plot(0, 0, 'ro');
%}
    
for i = 1:num_corner
    left_ind =  x(i) - floor(window_size/2);
    right_ind = x(i) + floor(window_size/2);
    up_ind = y(i) - floor(window_size/2);
    down_ind = y(i) + floor(window_size/2);
    
    windowz = I(up_ind:down_ind, left_ind:right_ind);
    %blur window
    windowz = conv2(windowz, Gaus, 'same');
    %subsample
    descriptor = windowz(1:sub:window_size, 1:sub:window_size);
    %{
    set(l1, 'xdata', [left_ind, right_ind],'ydata', [up_ind, up_ind])
    set(l2, 'xdata', [left_ind, right_ind],'ydata', [down_ind, down_ind])
    set(l3, 'xdata', [right_ind, right_ind], 'ydata', [up_ind, down_ind])
    set(l4, 'xdata', [left_ind, left_ind], 'ydata', [up_ind, down_ind])
    set(cnr, 'xdata', (left_ind+right_ind)/2, 'ydata', (up_ind+down_ind)/2)
    figure(4)
    imshow(uint8(windowz))
    figure(5)
    imshow(uint8(descriptor))
    %}
    %try this, normalize patch so the corners will be robust to
    %illumination
    descriptor = descriptor/norm(descriptor);
    p(:, i) = descriptor(:);
end



end

