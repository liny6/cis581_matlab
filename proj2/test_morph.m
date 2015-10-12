im1 = imread('trump.jpg');
im2 = imread('clinton.jpg');

choice = questdlg('use', 'choose point source','new points','existing points', 'new points');

if strcmp(choice, 'new points')
    [im1_pts, im2_pts] = click_correspondences(im1, im2); 
    save('correspondence.mat', 'im1_pts', 'im2_pts');
else 
    load('correspondence.mat', 'im1_pts', 'im2_pts');
end

tri = GetTri(im1_pts, im2_pts);
morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, 0.9, 0.5);

imshow(morphed_im)