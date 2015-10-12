function [f precision recall] = edgeEval(E, groundTruth)

E = double(E);
accP = zeros(size(E));
maxDist = 0.0075;
for i = 1:length(groundTruth)
    % compute the correspondence
    [match1,match2] = correspondPixels(E, double(groundTruth{i}.Boundaries), maxDist);
    % accumulate machine matches
    accP = accP | match1;
    % compute recall
    sumR = sum(groundTruth{i}.Boundaries(:));
    cntR = sum(match2(:)>0);
end

sumP = sum(E(:));
cntP = sum(accP(:));
precision = cntP / sumP;
recall = cntR / sumR;
f = 2*precision*recall / (precision+recall);

