function [ m ] = feat_match(p1, p2)
%descriptor matching
% % p1 = 64xn1 matrix of double values in the same format as the output from function
% feat_desc above.
% p2 = 64xn2 matrix of double values in the same format as the output from function
% feat_desc above.
% m = n1x1 vector of integers where m(i) points to the index of the descriptor in p2 that
% matches with the descriptor p1(:,i). If no match is found for feature i, you should put
% m(i)=-1.

[~, n1] = size(p1);
[~, n2] = size(p2);

SSD = zeros(n1, n2);

%calculate squared error matrix
for i = 1:n1
    dist = bsxfun(@minus, p1(:, i), p2);
    SSDn = sum(dist.^2);  
    SSD(i, :) = SSDn;
end
%caculate 4 nearest neighbors for both p1 and p2
p1_nn_ind = zeros(n1, 4);
p1_nn_val = zeros(n1, 4);

p2_nn_ind = zeros(n2, 4);
p2_nn_val = zeros(n2, 4);

%find 4 nearest neighbors for each feature in p1
for i = 1:n1
    SSDn = SSD(i, :);
    
    [nn1_val, nn1_ind] = min(SSDn);
    SSDn(nn1_ind) = inf;
    
    [nn2_val, nn2_ind] = min(SSDn);
    SSDn(nn2_ind) = inf;
    
    [nn3_val, nn3_ind] = min(SSDn);
    SSDn(nn3_ind) = inf;
    
    [nn4_val, nn4_ind] = min(SSDn);

    p1_nn_ind(i, :) = [nn1_ind, nn2_ind, nn3_ind, nn4_ind];
    p1_nn_val(i, :) = [nn1_val, nn2_val, nn3_val, nn4_val];
end

%find 4 nearest neighbors for each feature in p2
%{
for i = 1:n2
    SSDn = SSD(:, i);
    
    [nn1_val, nn1_ind] = min(SSDn);
    SSDn(nn1_ind) = inf;
    
    [nn2_val, nn2_ind] = min(SSDn);
    SSDn(nn2_ind) = inf;
    
    [nn3_val, nn3_ind] = min(SSDn);
    SSDn(nn3_ind) = inf;
    
    [nn4_val, nn4_ind] = min(SSDn);

    p2_nn_ind(i, :) = [nn1_ind, nn2_ind, nn3_ind, nn4_ind];
    p2_nn_val(i, :) = [nn1_val, nn2_val, nn3_val, nn4_val];
end
%}
%for debugging
for i = 1:length(p1_nn_ind)
    ind1 = p1_nn_ind(i, 1);
    ind2 = p1_nn_ind(i, 2);
    ind3 = p1_nn_ind(i, 3);
    ind4 = p1_nn_ind(i, 4);
    %{
    figure(3)
    imagesc(uint8(reshape(p1(:, i), [8 8])));    
    figure(4)
    imagesc(uint8(reshape(p2(:, ind1), [8, 8])));
   
    figure(5)
    imagesc(uint8(reshape(p2(:, ind2), [8, 8])));
    figure(6)
    imagesc(uint8(reshape(p2(:, ind3), [8, 8])));
    figure(7)
    imagesc(uint8(reshape(p2(:, ind4), [8, 8])));
    %}
end

threshold = 0.25;

ratio = p1_nn_val(:,1)./p1_nn_val(:,2);
%ratio2 = p2_nn_val(:,1)./p2_nn_val(:,2);
m = p1_nn_ind(:,1);
m(ratio < threshold) = -1;

end