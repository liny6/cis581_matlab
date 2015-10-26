im1 = imread('im1_blending.jpg');
im2 = imread('im2_blending.jpg');

imblend = twoBandBlending(im1, im2);

figure(3)
imshow(imblend)