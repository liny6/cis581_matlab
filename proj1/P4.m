I_a = [1 1 1 1 1 0 0 0 0 0];
I_b = [0 0 0 0 1 1 1 0 0 0];
I_c = [0 0 0 1 1 1 2 2 2 2];

G = 1/20*[1 5 8 5 1];
ddx = [1 -1];

I_a_gradient = conv2mirror(I_a, ddx, 0, 1, 0, 0);
I_a_smooth = conv2mirror(I_a, G, -2, 2, 0, 0);
I_a_smooth_gradient = conv2mirror(I_a_smooth, ddx, 0, 1, 0, 0);


I_b_gradient = conv2mirror(I_b, ddx, 0, 1, 0, 0);
I_b_smooth = conv2mirror(I_b, G, -2, 2, 0, 0);
I_b_smooth_gradient = conv2mirror(I_b_smooth, ddx, 0, 1, 0, 0);

I_c_graident = conv2mirror(I_c, ddx, 0, 1, 0, 0);
I_c_smooth = conv2mirror(conv2mirror(I_c, G, -2, 2, 0, 0), G, -2, 2, 0, 0);
I_c_smooth_gradient = conv2mirror(I_c_smooth, ddx, 0, 1, 0, 0);