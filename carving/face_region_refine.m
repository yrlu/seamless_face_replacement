function minEmask = face_region_refine(edgeMap, face, contour_pts)
% output: 
%   minEmask: h*w mask calculated with min energy seam
% inputs:
%   edgeMap: h*w edge map
%   face: face_struct
img_width = size(edgeMap, 2);
img_height = size(edgeMap, 1); 
% get nose position and radius
% img_width = face.img_width;
% img_height = face.img_height;
% ctr = getfield(face.landmark_points, 'nose_contour_lower_middle');
% noseX = ctr.x * img_width / 100;
% noseY = ctr.y * img_height / 100;
noseX = double(face(34,1));
noseY = double(face(34,2));
x_dist = contour_pts(:,1)-noseX;
y_dist = contour_pts(:,2)-noseY;
r_dist = (x_dist.^2 + y_dist.^2).^0.5;
rmax = floor(max(r_dist));
rmin = 1;
nr = (rmax-rmin)*2;
nw = 360;

% transform to log-polar, carve
log_arr = logsample(edgeMap, rmin, rmax, noseX, noseY, nr, nw); 

% 2. transform to polar, carve
% polar_arr = polarsample(edgeMap, rmin, rmax, noseX, noseY, nr, nw);

contour_choices= [1:27];
contour = [contour_pts(contour_choices,1), contour_pts(contour_choices,2)];

[r, p] = getPolarCtrlPts(contour, noseX, noseY, nr, nw, rmax, rmin);
rm_arr = getPolarCarve(log_arr, nr, nw, [r, p]);
% 2. rm_arr = getPolarCarve(polar_arr, nr, nw, [r, p]);

% transfer back and impose offet
arr_back = logsampback(rm_arr, rmin, rmax);
% 2 arr_back = polarsback(rm_arr, rmin, rmax);
[box_h, ~] = size(arr_back);
[row_carv_p, col_carv_p] = find(arr_back ~= 0);
carv_size = size(row_carv_p,1);
row_carv = uint32(row_carv_p)+repmat(uint32(noseY-box_h/2), [carv_size,1]);
col_carv = uint32(col_carv_p)+repmat(uint32(noseX-box_h/2), [carv_size,1]);

minLinear = sub2ind([img_height, img_width], row_carv, col_carv);
minEmask = zeros(img_height,img_width);
minEmask(minLinear) = 1;
minEmask = imclose(minEmask,strel('disk', 15));
minEmask = imfill(minEmask, 'holes');
end


