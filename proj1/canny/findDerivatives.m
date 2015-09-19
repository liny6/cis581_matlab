function [J, theta, Jx, Jy] = findDerivatives(I, Gx, Gy)
    %define derivative kernel
    ddx = [1, 0, -1];
    ddy = ddx';
    %convolve the kernel with derivative
    Gx = conv2(Gx, ddx);
    Gy = conv2(Gy, ddy);
    
    %calculate final kernel size to pad array correctly
    G_sizex = numel(Gx);
    G_sizey = numel(Gy);
    
    pad_sizex = double(G_sizex - 1)/2;
    pad_sizey = double(G_sizey - 1)/2;
    
    %first pad the image depending on the kernel size
    I_padded_x = double(padarray(I, [0, pad_sizex], 'symmetric'));
    I_padded_y = double(padarray(I, [pad_sizey, 0], 'symmetric'));
    %get the gradients
    Jx = conv2(I_padded_x, Gx, 'valid');
    Jy = conv2(I_padded_y, Gy, 'valid');
    %calculate theta
    angle = atan2(Jy, Jx);
    %% Edge angle conditioning
    angle(angle<0) = pi+angle(angle<0);
    angle(angle>7*pi/8) = pi-angle(angle>7*pi/8);
    % Edge angle discretization into 0, pi/4, pi/2, 3*pi/4
    angle(angle>=0&angle<pi/8) = 0;
    angle(angle>=pi/8&angle<3*pi/8) = pi/4;
    angle(angle>=3*pi/8&angle<5*pi/8) = pi/2;
    angle(angle>=5*pi/8&angle<=7*pi/8) = 3*pi/4;
    theta = angle;
    %calculate magnitude
    J = sqrt(Jx.^2 + Jy.^2);
end