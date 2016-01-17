%% Rocky

I1 = imread('v1.jpg');
I2 = imread('v2.jpg');
I3 = imread('v3.jpg');
I12 = my_mosaic(I2, I1);
I123 = my_mosaic(I12, I3);


%% mountain
%{
I1 = imread('m1.jpg');
I2 = imread('m2.jpg');
I3 = imread('m3.jpg');
I12 = my_mosaic(I2, I1);
I123 = my_mosaic(I12, I3);
%}

%% modlab
%{
I1 = imread('modlab1.jpg');
I2 = imread('modlab2.jpg');

I12 = my_mosaic(I2, I1);
%}