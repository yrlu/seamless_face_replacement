% Crop a single face from the image by face's landmark
% 
% @author Yiren Lu
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/18/2016
% 
% @input    img         hxwx3 image
%           face        detected face struct
% @output   BW          hxw binary mask for face
%           faces_img   hxwx3 masked face
%           ctl_pts     #landmarkx2 control points
function [BW, masked_face, ctl_pts, contour_pts] = crop_face_dlib(img, face)
[h,w,~] = size(img);
ctl_pts = double(face);
k = convhull(ctl_pts(:,1),ctl_pts(:,2));
contour_pts = [ctl_pts(k,1),ctl_pts(k,2)];
BW = poly2mask(ctl_pts(k,1), ctl_pts(k,2), h, w);
masked_face = uint8(repmat(BW, [1,1,3])).*uint8(img);
end