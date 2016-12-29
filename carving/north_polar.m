%% face log-polar test base
% get nose location
img = uint8(v.v_mat(:,:,:,1));
face = sample_out{1,1}{1,1};
center = face.center;
img_width = face.img_width;
img_height = face.img_height;

%%
imshow(img);
hold on;
ctr = getfield(face.landmark_points, 'nose_contour_lower_middle');
scatter(ctr.x * img_width / 100, ctr.y * img_height / 100, 'r*');
%
noseX = ctr.x * img_width / 100;
noseY = ctr.y * img_height / 100;
% find rmin, rmax parameter
% rmax -> contour
ctl_pts1 = zeros(83,2); % 83 * [x,y];
for j = 1 : length(face.landmark_names)
    pt = getfield(face.landmark_points, face.landmark_names{j});
    ctl_pts1(j, :) = [pt.x * img_width / 100, pt.y * img_height / 100];
    scatter(pt.x * img_width / 100, pt.y * img_height / 100, 'g.');
end
K = convhull(ctl_pts1(:,1),ctl_pts1(:,2));
plot(ctl_pts1(K,1), ctl_pts1(K,2),'r-');


%%
nr = rmax-rmin;
rm_arr2 = getPolarCarve(log_arr, nr, nw);


%%
e = genEngMap(log_arr);
e = e;
%% we enforce the choose the of angle by setting other angle-starter very expensive.
r_starter = nr -1;
r_chosen = e(1,r_starter);
e(1,:) = nw*100;
e(1,r_starter) = r_chosen;
[Mx, Tbx] = cumMinEngVer(e);

%% r_end = r_starter
rm_arr = zeros(nw, nr);
rm_arr(1,r_starter) = 1;
rm_arr(end, r_starter) = 1;
path = r_starter;
for i = 360-1:-1:1
    path = Tbx(i+1, int64(path));
    rm_arr(i,path) = 1;
end


%%

[box_h, ~] = size(arr_back3);
[row_carv_p, col_carv_p] = find(arr_back3 ~= 0);
carv_size = size(row_carv_p,1);
row_carv = uint32(row_carv_p)+repmat(uint32(noseY-box_h/2), [carv_size,1]);
col_carv = uint32(col_carv_p)+repmat(uint32(noseX-box_h/2), [carv_size,1]);
%%
%+center_off_y-
%+center_off_x-
K = convhull(double(row_carv), double(col_carv));
minLinear = sub2ind([img_height, img_width], row_carv(K), col_carv(K));
minEmask = zeros(img_height,img_width);
minEmask(minLinear) = 1;
%%
imshow(uint8(img))
%%
figure;
imagesc(genEdgeMap(img))
hold on;
 plot(col_carv, row_carv,'r.')
%% write it polar
% center around nose
[coord_x, coord_y] = meshgrid(1:img_width, 1:img_height);
total_pixel = img_height*img_width;
coord_x = reshape(coord_x - noseX, [total_pixel,1]);
coord_y = reshape(coord_y - noseY, [total_pixel,1]);
[theta, rho] = cart2pol(coord_x, coord_y);
log_r = log(rho);


%
%% get parameters
x_dist = ctl_pts1(K,1)-noseX;
y_dist = ctl_pts1(K,2)-noseY;
r_dist = (x_dist.^2 + y_dist.^2).^0.5;
rmax = floor(max(r_dist));
%rmax= rmax +100;
%

% rmin -> eyes, mouths.... 

rmin = 1;
nr = (rmax-rmin)*2;
nw = 360;

log_arr = logsample(img, rmin, rmax, noseX, noseY, nr, nw);

%  36 82
contour_choices= [1 5 15];

contour = [ctl_pts1(contour_choices,1), ctl_pts1(contour_choices,2)];

% chin, left, right, upper-left, upper-right;


[r, p] = getPolarCtrlPts(contour, noseX, noseY, nr, nw, rmax, rmin);

%
rm_arr2 = getPolarCarve(log_arr, nr, nw, [r, p]);
%
arr_back3 = logsampback(rm_arr2, rmin, rmax);
arr_rt2 = arr_back3 ~= 0;
% transfered back
arr = logsampback(log_arr, rmin, rmax);
imshow(arr);
% -> 
arr(arr_rt2) = 0;
hold on;
imshow(arr);

%%
test1 = ones(400, 400);
%test1(50:150, 50:150,:) = 1;
%test1(150:200, 100:150, :) = 1;
% e = genEdgeMap(test1);
e = test1;
rmin = 1;
rmax = 100;
xc = 100; 
yc = 100;
nr = 100; 
nw = 360;
contour_pts = [150, 150; 50, 50];
%log_arr = logsample(e, rmin, rmax, xc, yc, nr, nw);
polar_arr = polarsample(e, rmin, rmax, xc, yc, nr, nw);

% log_back = logsampback(log_arr, rmin, rmax);
polar_back = polarsback(polar_arr, rmin, rmax);
 [th_r, p_d] = getPolarCtrlPts(contour_pts, xc, yc, nr, nw, rmax, rmin);
rm_arr = getPolarCarve(polar_arr, nr, nw, [th_r, p_d]);

%rm_back = logsampback(rm_arr, rmin, rmax);
rm_back = polarsback(rm_arr, rmin, rmax);
%imshow(rm_back);

[box_h, ~] = size(rm_back);
[row_carv_p, col_carv_p] = find(rm_back);
carv_size = size(row_carv_p,1);
row_carv = uint32(row_carv_p)+repmat(uint32(xc-box_h/2), [carv_size,1]);
col_carv = uint32(col_carv_p)+repmat(uint32(yc-box_h/2), [carv_size,1]);
scatter(col_carv, row_carv);