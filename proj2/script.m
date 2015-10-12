im1 = imread('seal.png');
im2 = imread('hotpot.jpg');

imblend = twoBandBlending(im1, im2);

figure(3)
imshow(imblend)