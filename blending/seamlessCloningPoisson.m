function resultImg = seamlessCloningPoisson(sourceImg, targetImg, mask, offsetX, offsetY)
% INPUT:    sourceImg   h x w x 3 matrix representing source image.
%           targetImg   h0 x w0 x 3 matrix representing target image.
%           mask        h x w logical matrix representing the replacement region.
%           offsetX     the x axis offset of source image regard of target image.
%           offsetY     the y axis offset of source image regard of target image.
% OUTPUT:   resultImg   h0 x w0 x 3 matrix representing blending image.
%
% @Author: Dongni W. 
% @Date: 11/28/16

[targetH, targetW, ~] = size(targetImg);
s_ind_trans = getIndexes(mask, targetH, targetW, offsetX, offsetY);
coefM = getCoefMatrix(s_ind_trans);
red = getSolutionVect(s_ind_trans, sourceImg(:,:,1), targetImg(:,:,1), offsetX, offsetY, coefM);
green = getSolutionVect(s_ind_trans, sourceImg(:,:,2), targetImg(:,:,2), offsetX, offsetY, coefM);
blue = getSolutionVect(s_ind_trans, sourceImg(:,:,3), targetImg(:,:,3), offsetX, offsetY, coefM);
resultImg = reconstructImg(s_ind_trans, red, green, blue, targetImg);
end