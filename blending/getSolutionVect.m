% Author: Yiren Lu
% luyiren@seas.upenn.edu
% Date: 11/27/2016
%
% INPUT:    indexes     H'xW' matrix representing the indices of each
%                       replacement pixel
%           source      HxW matrix representing one channel of source img
%           target      HxW matrix representing one channel of target img
%           offsetX     the x axis offset of source image regard of target 
%                       image.
%           offsetY     the y axis offset of source image regard of target 
%                       image.
% OUTPUT:   solVector   1 × n vector representing the solution vector.
function solVector = getSolutionVect(indexes, source, target, offsetX, offsetY, coefM)
if nargin == 5
coefM = getCoefMatrix(indexes);
end

[s_h, ~] = size(source);
[h, ~] = size(target);
% y = |N_p|g_p - sum_{q\in N_p} g_q + sum_{q\in N_p} 1(q \in \partial\omega)*f_q^*
n = max(indexes(:));
y = zeros(n, 1);
indices = find(indexes>0);
for i = 1:n
idx = indices(indexes(indices)==i);
% idx - h - 1 | idx-1   | idx + h - 1
% idx - h     | idx     | idx + h
% idx - h + 1 | idx+1   | idx + h + 1
N_indices = [idx-1;idx-h-1;idx-h;idx-h+1;idx+1;idx+h+1;idx+h;idx+h-1];
N_indices_in = N_indices > 0 & N_indices < numel(indexes);
N_indices_bd = N_indices > 0 & N_indices < numel(indexes) & indexes(N_indices) == 0;

y_s_n = int64(mod(N_indices(N_indices_in), h));
x_s_n = int64(N_indices(N_indices_in) / h);
y_s_n = y_s_n - offsetY;
x_s_n = x_s_n - offsetX;
s_idx_n = (x_s_n-1)*int64(s_h) + y_s_n;

y_s = int64(mod(idx, h));
x_s = int64(idx/ h);
y_s = y_s - offsetY;
x_s = x_s - offsetX;
s_idx = (x_s-1)*int64(s_h) + y_s;

y(i) = 8*int64(source(s_idx)) - sum(int64(source(s_idx_n))) + sum(int64(target(N_indices(N_indices_bd))));
end
solVector = coefM\y;
solVector = uint8(solVector);
end