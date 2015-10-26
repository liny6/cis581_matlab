function p = ExtractDes(I, y, x)
%extract feature descriptor
%let's get a 8x8 patch describing each corner
%p is a 64xn matrix

I = double(I);

[nr, nc] = size(I);


%first we start at each corner location and take a 40x 40 window
window_size = 40;
p_size = 8;
sub = window_size/p_size;
x_pad = window_size/2;
y_pad = window_size/2;
%{
%remove everything that has window outside the image, they are not good
%features to match anyways

x_bool_l = x > window_size;
x_bool_r = x < nc - window_size;
y_bool_u = y > window_size;
y_bool_d = y < nr - window_size;

%boolean for the corners i want to keep
keep = bitand(bitand(x_bool_l, x_bool_r), bitand(y_bool_u, y_bool_d));

x = x(keep);
y = y(keep);


%}
%pad the image

num_corner = length(y);
I_padded = padarray(I, [x_pad, y_pad]);

p = zeros(p_size^2, num_corner);

%gaussian kernel for blurring, 9x9 here
Gaus = normpdf(-4:1:4, 0, 1);
Gaus = conv2(Gaus, Gaus');

for i = 1:num_corner
    left_ind =  x(i) - floor(window_size/2) + x_pad;
    right_ind = x(i) + floor(window_size/2) + x_pad;
    up_ind = y(i) - floor(window_size/2) + y_pad;
    down_ind = y(i) + floor(window_size/2) + y_pad;
    
    windowz = I_padded(up_ind:down_ind, left_ind:right_ind);
    %blur window
    windowz = conv2(windowz, Gaus, 'same');
    %subsample
    descriptor = windowz(1:sub:window_size, 1:sub:window_size);
    p(:, i) = descriptor(:);
end



end

