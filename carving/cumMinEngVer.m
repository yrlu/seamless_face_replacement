% Author: Yiren Lu & Dongni Wang
% luyiren@seas.upenn.edu
% Date: 11/27/2016
%
% Cumulative Min Energy
% INPUT:    e       HxW the edge map
% OUTPUT:   Mx      HxW the cumulative minimum energy map along the
%                   horizontal direction
%           Tbx     HxW the backtrack table along the horizontal direction
function [Mx, Tbx] = cumMinEngVer(e)
[ny,nx] = size(e);
Mx = zeros(ny, nx);
Tbx = zeros(ny, nx);
Mx(1,:) = e(1,:);

Mx2 = Inf(ny, nx+2);
Mx2(1,2:end-1) = e(1,:);

for i = 2:ny
    %                            1:left,        2:straight,      3:right
    [min_val, min_idx] = min([Mx2(i-1, 1:end-2); Mx2(i-1,2:end-1);  Mx2(i-1, 3:end)]);
    Mx2(i,2:end-1) = e(i,:) + min_val;
    Tbx(i,:) = 1:nx;
    Tbx(i,:) = Tbx(i,:) + (min_idx - 2);
end

Mx = Mx2(:, 2:end-1);
end