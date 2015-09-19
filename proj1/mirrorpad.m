function I_padded = mirrorpad(I, x_min, x_max, y_min, y_max)

right_pad = I(:, (end-x_max):(end-1));
right_pad = fliplr(right_pad);

if x_min < 0
    left_pad = I(:, 2:((2-1-x_min)));
    left_pad = fliplr(left_pad);
    I_padded = [left_pad, I, right_pad];
else 
    I_padded = [I, right_pad];
end

bottom_pad = I_padded( (end-y_max):(end-1), : );
bottom_pad = flipud(bottom_pad);

if y_min < 0
    top_pad = I_padded(2:(2-1-y_min), :);
    top_pad = flipud(top_pad);
    I_padded = [top_pad; I_padded; bottom_pad];
else
    I_padded = [I_padded; bottom_pad];
end