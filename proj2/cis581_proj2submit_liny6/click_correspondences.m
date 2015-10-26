function [ im1_pts, im2_pts ] = click_correspondences( im1, im2 )
%this defines the corresponding points in the images
%where im1 pts and im2 pts ( both n-by-2 matrices of (x,y) locations) defines corresponding
%points in two images.

 f1 = figure(1);
 f1.OuterPosition = [150 466 700 700];
 imshow(im1)
 f2 = figure(2);
 f2.OuterPosition = [930 466 700 700];
 imshow(im2)

 GetMorePoints = 'Yes';
 pt_count = 1;
 
 im1_pts = zeros(1, 2);
 im2_pts = zeros(1, 2);
 
 while(strcmp(GetMorePoints, 'Yes'))
     figure(1)
     im1_pts(pt_count, :) = ginput(1);
     hold on
     plot(im1_pts(pt_count,1), im1_pts(pt_count,2), 'r*')
     text(im1_pts(pt_count,1)+5, im1_pts(pt_count,2), sprintf('%d', pt_count))
     hold off
     figure(2)
     im2_pts(pt_count, :) = ginput(1);
     hold on
     plot(im2_pts(pt_count,1), im2_pts(pt_count,2), 'r*')
     text(im2_pts(pt_count,1)+5, im2_pts(pt_count,2), sprintf('%d', pt_count))
     hold off
     pt_count = pt_count + 1;
     GetMorePoints = questdlg('More points?');
 end

 close all;
