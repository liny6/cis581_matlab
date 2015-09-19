function I_out = myImcrop( I_in )
%MYIMCROP Summary of this function goes here
%   Detailed explanation goes here
figure
imshow(I_in);
[x, y] = ginput(2);
I_out = I_in(floor(min(y)):floor(max(y)), floor(min(x)):floor(max(x)), : );
figure
imshow(I_out);
end

