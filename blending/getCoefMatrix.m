% Author: Yiren Lu
% luyiren@seas.upenn.edu
% Date: 11/27/2016
%
% INPUT:    indexes     H'xW' matrix representing the indices of each
%                       replacement pixel
% OUTPUT:   coefM       n × n sparse matrix representing the coefficient 
%                       matrix. n is the number of replacement pixels.
function coefM = getCoefMatrix(indexes)
% fully vectorized
n = max(indexes(:));
[h, w] = size(indexes);
coefM = sparse(n, n);
coefM(1:n+1:end) = 8;
idx = find(indexes>0);
% idx - h - 1 | idx-1   | idx + h - 1
% idx - h     | idx     | idx + h
% idx - h + 1 | idx+1   | idx + h + 1
N_indices = [idx-1;idx-h-1;idx-h;idx-h+1;idx+1;idx+h+1;idx+h;idx+h-1];
is = repmat(indexes(idx), [1, 8]);
N_q_idx_in = N_indices > 0 & N_indices < numel(indexes) & indexes(N_indices) ~= 0;
coefM( (round(indexes(N_indices(N_q_idx_in))) - 1)*n + is(N_q_idx_in) ) = -1;
end
