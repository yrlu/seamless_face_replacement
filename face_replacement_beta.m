% Face replacement
%   - face morphing 
%   - face carving
%   - face blending
% 
% @author Yiren Lu & Dongni Wang
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/18/2016
% 
% @input    img_src         source image with replacement face [uint8 0-255]
%           img_dst         target image with face to be replaced [uint8 0-255]
%           face_src        face information for replacement face
%           face_dst        face information for face to be replaced
% @output   img_res         result image with target face being replaced by
%                           replacement face [uint8 0-255]
function [img_res, final_mask] = face_replacement_beta(img_src, img_dst, face_src, face_dst)
[~, masked_face_src, ctl_pts_src] = crop_face_dlib(img_src, face_src);
[BW_dst, masked_face_dst, ctl_pts_dst] = crop_face_dlib(img_dst, face_dst);

% disp 'morphing'
addpath ./morphing/
face_morphed = morph_tps_wrapper(masked_face_src, masked_face_dst, ctl_pts_src, ctl_pts_dst, 1, 0);
% disp 'carving'
% tic 
addpath ./carving/
% face_morphed2 = face_morphed;
% face_morphed2(face_morphed==0) = Inf;
% face_morphed2 = zeros(size(face_morphed2,1),size(face_morphed2,2), 3);
% face_morphed2(200:400, 200:400,:) = 1;
carve_mask = face_region_refine(genEdgeMap(face_morphed), face_dst, ctl_pts_dst);
% toc
% disp 'blending'
addpath ./blending/
mask = BW_dst&(face_morphed(:,:,1)~=0);
se = strel('sphere',5);
mask = imerode(mask,se);
%
final_mask = mask&carve_mask;
img_res = seamlessCloningPoisson(face_morphed, img_dst, final_mask, 0, 0);
end