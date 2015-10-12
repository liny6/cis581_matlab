function [ im_blend, im1_low, im1_high, im2_low, im2_high ] = twoBandBlending( im1, im2 )


bd_width = 3;

figure(1)
imshow(im1);
figure(2)
imshow(im2);
figure(1)
questdlg('please select the boundary of the first image which you would like to morph to the second image', 'ok', 'ok')
[x(1), y(1)] = ginput(1);
hold on
plot(x(1), y(1), 'r*')
[x(2), y(2)] = ginput(1);

x = round(x);
y = round(y);

x=sort(x);
y=sort(y);


Gx = normpdf(-5:1:5, 0, 1);
Gy = normpdf(-5:1:5, 0, 1)';
Gxy = conv2(Gx,Gy);

[nr, nc, colors] = size(im1);

im_blend = zeros(nr,nc,colors);

for i = 1:colors
    
im1i = double(im1(:,:,i));
im2i = double(im2(:,:,i));

im1_low = conv2(im1i, Gxy, 'same');
im2_low = conv2(im2i, Gxy, 'same');

im1_high = im1i - im1_low;
im2_high = im2i - im2_low;


[r, c] = meshgrid(1:nr, 1:nc);
w_binary = rem(1+r+c, 2);


im_blend_high = im1_high.*w_binary + im2_high.*(1-w_binary);

w_linear = zeros(nr, nc);
%left boundary
w_linear(y(1)+1 : y(2), x(1) - bd_width: x(1) + bd_width) = repmat(linspace(0, 1, bd_width*2 + 1), [y(2) - y(1), 1]);
%right boundary
w_linear(y(1)+1 : y(2), x(2) - bd_width: x(2) + bd_width) = repmat(linspace(1, 0, bd_width*2 + 1), [y(2) - y(1), 1]);
%top boundary
w_linear(y(1) : y(1)+bd_width*2, x(1)+1 : x(2) ) = repmat(linspace(0, 1, bd_width*2 +1 )', [1, x(2) - x(1)]);
%bottom boundary
w_linear(y(2) - bd_width*2 : y(2), x(1)+1 : x(2) ) = repmat(linspace(1, 0, bd_width*2 +1 )', [1, x(2) - x(1)]);
%fill
w_linear(y(1) + bd_width*2 : y(2) - bd_width*2, x(1) + bd_width: x(2) - bd_width) = ones(y(2) - y(1) - bd_width*4 +1, x(2) - x(1) - 2*bd_width +1);
%w_linear(:, floor(nc/2) + 6 : end) = ones(nr, nc - (floor(nc/2) + 5));
%{
w_linear(x(1):x(2), y(1):y_mid) = repmat(linspace(0, 1, abs(y(1)-y_mid)+1),[abs(x(1)-x(2))+1, 1]);
w_linear(x(1):x(2), y_mid:y(2)) = repmat(linspace(1, 0, abs(y_mid-y(2))+1),[abs(x(1)-x(2))+1, 1]);
w_linear_x1 = linspace(0, 1, abs(y(1)-y_mid));
w_linear_x2 = linspace(1, 0, abs(y(2)-y_mid));
w_linear_y1 = linspace(0, 1, abs(x(1)-x_mid))';
w_linear_y2 = linspace(1, 0, abs(x(2)-x_mid))';

w_linear_x = [w_linear_x1, 1, w_linear_x2];
w_linear_y = [w_linear_y1; 1; w_linear_y2];

line_patch = conv2(w_linear_x, w_linear_y);

w_linear(x(1):x(2), y(1) : y(2)) = line_patch;
%w_linear() = repmat(linspace(0, 1, 11), [nr, 1]);
%}
im_blend_low = im1_low.*w_linear + im2_low.*(1-w_linear);

im_blend(:,:,i) = im_blend_high + im_blend_low;
end

im_blend = uint8(im_blend);

end

