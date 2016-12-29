% [indexes] = getIndexes(mask, targetH, targetW, offsetX, offsetY)
% (INPUT) mask: h x w logical matrix representing the replacement region.
% (INPUT) targetH: target image height, h0.
% (INPUT) targetW: target image width, w0.
% (INPUT) offsetX: the x axis offset of source image regard of target image.
% (INPUT) offsetY: the y axis offset of source image regard of target image.
% (OUTPUT) indexes: h0 x w0 matrix representing the indices of each replacement
%                   pixel. 0 means not a replacement pixel.
%
%@author: Dongni W.
%@date: 11/27/16
function indexes = getIndexes(mask, targetH, targetW, offsetX, offsetY)
indexes = zeros(targetH, targetW);
[s_col, s_row] = find(mask'); % transpose so that search by row
t_indexes = [s_row+offsetY, s_col+offsetX];
% boundary check:
within_region = true(1, size(t_indexes, 1));
out_y = t_indexes(:,1) > targetH;
out_x = t_indexes(:,2) > targetW; 
within_region(out_y) = false;
within_region(out_x) = false;
t_indexes = t_indexes(within_region, :);
% convert [row, col] subscript to (ind)
t_ind = sub2ind(size(indexes), t_indexes(:,1), t_indexes(:,2));
rep_nums = 1:size(t_ind,1);
% output: zeros or replacement indices
indexes(t_ind) = rep_nums;
end
