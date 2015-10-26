function [y, x, rmax] = ANMS(R, max_pts)
%this supresses excessive corners using adaptive non maximum supression,
%the input argument R is the cornerness map from FindCornerMap, des_num_corners
%is the desired number of corners. The output argument y and x corresponds
%to the corner coordinate and rmax is the maximum radius which the point
%can be considered as a corner

[nr, nc] = size(R);
threshold = 10000;
R = R(:);
Sup = R > threshold;
inds = 1:nr*nc;

R_data = [R(Sup), inds(Sup)', zeros(length(R(Sup)), 1)];%dumb data structure

for i = 1:length(R_data) %for each qualified corners
    
    cornerer_bool = R_data(:,1) > R_data(i, 1); %find the points that are greater than me
    cornerer_bool(i) = 0; %prevent canceling myself out
    cornerer_ind = R_data(cornerer_bool, 2);
    if isempty(cornerer_ind)
        r = inf;
    else
        [y_cur, x_cur] = ind2sub([nr, nc], R_data(i ,2)); %back out the x, y position from my position
        [y_s, x_s] = ind2sub([nr, nc], cornerer_ind);%back out the x, y position for cornerer points
        dysq = (y_s - y_cur).^2;
        dxsq = (x_s - x_cur).^2;
        dist = sqrt(dysq+dxsq);
        r = min(dist);
    end
    R_data(i, 3) = r;
end



%sort R_data based on the radius length, which is the 3rd column
R_data = flipud(sortrows(R_data, 3));
%truncate excessive points
rmax = R_data(1: max_pts, 3);
[y, x] = ind2sub([nr, nc], R_data(1:max_pts, 2));
end


%{
radius_mat = zeros(nr,nc);

for j = 1:nr
    for i = 1:nc
        
        window_size = 1;
        
        left = max(1, i-window_size);
        right = min(nc, i+window_size);
        up = max(1, j-window_size);
        down = min(nr, j+window_size);
        
        window = R(up:down, left:right);
        
        [row_max, row_max_ind] = max(window);
        [window_max, column_max_ind] = max(row_max);
        
        
        while (R(j, i) >= window_max && right < nc && down < nr)
            
            window_size = window_size + 1;
            left = max(1, i-window_size);
            right = min(nc, i+window_size);
            up = max(1, j-window_size);
            down = min(nr, j+window_size);
            
            window = R(up:down, left:right);
            
            [row_max, row_max_ind] = max(window);
            [window_max, column_max_ind] = max(row_max);           
        end
        
        window_max_ind = [row_max_ind(column_max_ind), column_max_ind];
        
        radius_mat(j, i) = norm(window_max_ind);
    end
end

radius_2_cols = [radius_mat(:), (1:nr*nc)'];
%}

