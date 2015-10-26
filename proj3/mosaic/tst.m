I = imread('lola.jpg');
%I = imread('check.jpg');
R = FindCornerMap(I);
figure(1)
imagesc(R)
[y, x, rmax] = ANMS(R, 50);
figure(2)
imshow(I)
figure(2)
hold on
figure(2)
plot(x, y, 'ro')