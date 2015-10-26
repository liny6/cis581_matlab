function [a1, ax, ay, w] = est_tps( ctr_tps, target_value )
%target value is one column vector bro
lambda = 0.0001;
l = length(ctr_tps);

x_diff = bsxfun(@minus, ctr_tps(:,1), ctr_tps(:,1)');
y_diff = bsxfun(@minus, ctr_tps(:,2), ctr_tps(:,2)');

rsq = (x_diff.^2 + y_diff.^2);

K = -rsq.*log(rsq);
K(isnan(K)) = 0;
P = [ctr_tps, ones(l, 1)];
O = zeros(3,3);

TPS_mat = [K , P; P', O];
TPS_stable = TPS_mat + lambda*eye(l+3);

param = TPS_stable\[target_value; 0; 0; 0];

w = param(1:l);
ax = param(l+1);
ay = param(l+2);
a1 = param(l+3);
end

