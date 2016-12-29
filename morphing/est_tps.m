function [a1, ax, ay, w] = est_tps(ctr_pts, target_value)
% Author: Max Lu
% Date: 10/17/2016
% luyiren@seas.upenn.edu
%
% Inputs:   ctr_pts     N x 2 matrix, each row representing corresponding
%                       points position (x, y) in second image
%           target_value    N x 1 vector representing corresponding point
%                           position x or y in first image
% Outputs:  a1          double, TPS parameter
%           ax          double, TPS parameter
%           ay          double, TPS parameter
%           w           N x 1 vector, TPS parameters

function [u] = U(r) 
u = -(r.^2.*log(r.^2));
u(isnan(u)) = 0;
end
p = size(ctr_pts, 1);
K = zeros(p, p);

[is, js] = meshgrid(1:p, 1:p);
is = is(:); js = js(:);
K((js-1).*p+is) = U(sqrt(sum((ctr_pts(is,:) - ctr_pts(js,:)).^2,2)));

P = [ctr_pts(1:p,:), ones(p,1)];

lambda = eps;
res = inv([K P; P' zeros(3,3)] + lambda*eye(p+3))*[target_value; zeros(3, 1)];
w = res(1:p);
ax = res(p+1);
ay = res(p+2);
a1 = res(p+3);

end