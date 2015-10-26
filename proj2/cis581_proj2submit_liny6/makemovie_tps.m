im1 = imread('trump.jpg');
im2 = imread('clinton.jpg');

choice = questdlg('use', 'choose point source','new points','existing points', 'new points');

if strcmp(choice, 'new points')
    [im1_pts, im2_pts] = click_correspondences(im1, im2); 
    save('correspondence.mat', 'im1_pts', 'im2_pts');
else 
    load('correspondence.mat', 'im1_pts', 'im2_pts');
end

frames = 60;
M(1:frames) = struct('cdata', [], 'colormap', []);
charstodelete = [];
fprintf('\n')
delstr = [];
for i = 1 : frames
    frac = 1/frames*i;
    morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, frac, frac);
    M(i) = im2frame(morphed_im);
    status_str = sprintf('on frame %d', i);
    if ~isempty(charstodelete)
        delstr = repmat('\b', 1, charstodelete);
    end
    charstodelete = numel(status_str);
    
    fprintf([delstr, status_str]);
end
movie(M);