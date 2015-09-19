I = [0 1 0.5 0.5 0 0.5 0.5 1 0 1 1;
     0 1 0.5 0.5 0 0.5 0.5 1 0 1 1;
     1 1 0.5 0.5 0 0.5 0.5 1 0 1 0;
     1 1 0   1   1  0   0  1 1 0 0;
     1 1 0.5 0.5 0 0.5  1  1 1 0 0;
     0 0 0.5 0.5 0 0.5  1  1 0 0 1;
     0 0 0.5 0.5 1  1   1  1 1 0 0];
 
a = 0.4;

Gx = [1/4-a/2, 1/4, a, 1/4, 1/4-a/2];
Gy = Gx';
delta_x = [1, -1];
delta_y = delta_x';

I_smooth = conv2mirror(conv2mirror(I, Gx, -2, 2, 0,0),Gy, 0, 0, -2, 2);
%I_smooth = I_smooth(3:end-2);

I_x = conv2mirror(I_smooth, delta_x, 0, 1, 0, 0);
I_y = conv2mirror(I_smooth, delta_y, 0, 0, 0, 1);

I_abs = sqrt(I_x.^2 + I_y.^2);