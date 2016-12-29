% Author: Yiren Lu
% luyiren@seas.upenn.edu
% Date: 11/27/2016
%
% INPUT:    indexes     H'xW' matrix representing the indices of each
%                       replacement pixel
%           red:        1 × n vector representing the red channel intensity
%                       of replacement pixel.
%           green:      1 × n vector representing the red channel intensity
%                       of replacement pixel.
%           blue:       1 × n vector representing the red channel intensity
%                       of replacement pixel.
%           targetImg   h'×w'×3 matrix representing target image.
% OUTPUT:   resultImg   h'×w'×3 matrix representing blending image.
function resultImg = reconstructImg(indexes, red, green, blue, targetImg)
[h,w,~] = size(targetImg);
resultImg = targetImg;
n = max(indexes(:));
indices = find(indexes>0);
for i = 1:n
idx = indices(indexes(indices)==i);
resultImg(idx) = red(i);
resultImg(idx+h*w) = green(i);
resultImg(idx+h*w*2) = blue(i);
end
resultImg = uint8(resultImg);
end