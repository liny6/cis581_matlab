function [a1,ax,ay,w, C] = est_tps(ctr_pts, target_value)
%A * B = v
Xc = ctr_pts(:,1);%control pys
Yc = ctr_pts(:,2);
V = [target_value;zeros(3,1)];
P = [ones(size(ctr_pts,1),1),ctr_pts];

r_sq = (repmat(Xc',size(Xc,1),1) - repmat(Xc,1,size(Xc,1))).^2 ... 
    + (repmat(Yc',size(Yc,1),1) - repmat(Yc,1,size(Yc,1))).^2;
K = r_sq.*log(r_sq);
K(isnan(K)) = 0;

A = [K, P; P', zeros(3,3)];
C = A + eps.*eye(size(ctr_pts,1)+3,size(ctr_pts,1)+3);
B = (A + eps.*eye(size(ctr_pts,1)+3,size(ctr_pts,1)+3))\V;

w = B(1:end-3);
a1 = B(end-2);
ay= B(end);
ax = B(end-1);
end