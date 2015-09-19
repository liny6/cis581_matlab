function I_out = conv2mirror(I_in, kernel, k_x_min, k_x_max, k_y_min, k_y_max)
%CONV2MIRROR Summary of this function goes here
%   Detailed explanation goes here
[I_size_y, I_size_x] = size(I_in);
[k_size_y, k_size_x] = size(kernel);

if I_size_y < k_size_y && I_size_x < k_size_x %if kernel is entered first
    %swap I and kernel
    temp = kernel;
    kernel = I_in;
    I_in = temp;
end
% make mirror padding
I_padded = mirrorpad(I_in, k_x_min, k_x_max, k_y_min, k_y_max);
I_out = conv2(I_padded, kernel,'valid');
end

