function [morphed_im] = morph(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
% Author: Max Lu
% Date: 10/17/2016
% luyiren@seas.upenn.edu

% Inputs:   im1     rgb first image
%           im2     rgb second image   
%           im1_pts     N*2 correspondences coordinates in first image
%           im2_pts     N*2 correspondences coordinates in second image
%           warp_frac           parameter to control shape warping
%           dissolve_frac       parameter to control cross-dissolve
% Output:   morphed_im          rgb image representing the morphed image

% Trianglation

% Take the mean of two sets of points
m_pts = (im1_pts+im2_pts)/2;

% Delaunay trianglation
TRI = delaunay(m_pts);

% Compute intermediate shape for a given warp_frac
im_pts = (1-warp_frac)*im1_pts + warp_frac*im2_pts;

% Compute the barycentric coordinate for each pixel
[x y] = ind2sub([size(im1,1), size(im1,2)],1:size(im1,1)*size(im1,2));
x = x';
y = y';
t = tsearchn(im_pts,TRI,[x y]);

% Inverse warping

% remove NaN points
in_trian = ~isnan(t);
t = t(in_trian);
% find correspondences in source image and destination image
Tris = TRI(t, :); % should be (h*w) by 3
morphed_im = zeros(size(im1));

x = x(in_trian);
y = y(in_trian);

mat_m = zeros(3,3,size(TRI,1));
inv_mat_m = zeros(3,3,size(TRI,1));
mat_s = zeros(3,3,size(TRI,1));
mat_d = zeros(3,3,size(TRI,1));

% compute tmp matrices
for i = 1:size(TRI,1)
    trian = TRI(i, :);
    mat_m(:,:,i) = [im_pts(trian(1), 1), im_pts(trian(2), 1), im_pts(trian(3), 1); im_pts(trian(1), 2), im_pts(trian(2), 2), im_pts(trian(3), 2);1,1,1];
    inv_mat_m(:,:,i) = inv(mat_m(:,:,i));
    mat_s(:,:,i) = [im1_pts(trian(1), 1), im1_pts(trian(2), 1), im1_pts(trian(3), 1); im1_pts(trian(1), 2), im1_pts(trian(2), 2), im1_pts(trian(3), 2);1,1,1];
    mat_d(:,:,i) = [im2_pts(trian(1), 1), im2_pts(trian(2), 1), im2_pts(trian(3), 1); im2_pts(trian(1), 2), im2_pts(trian(2), 2), im2_pts(trian(3), 2);1,1,1];
end

% Blending according to dissolve_frac
for i = 1:numel(x)
    bary_centric_cood = inv_mat_m(:,:,t(i))*[x(i);y(i);1];
    
    xyz_s = mat_s(:,:,t(i))*bary_centric_cood;
    xyz_s = xyz_s/xyz_s(3);
    xyz_s(1) = max(min(xyz_s(1), size(im1,1)), 1);
    xyz_s(2) = max(min(xyz_s(2), size(im1,2)), 1);
    
    xyz_d = mat_d(:,:,t(i))*bary_centric_cood;
    xyz_d = xyz_d/xyz_d(3);
    xyz_d(1) = max(min(xyz_d(1), size(im2,1)), 1);
    xyz_d(2) = max(min(xyz_d(2), size(im2,2)), 1);
    
    pxl1 = im1(int64(xyz_s(1)), int64(xyz_s(2)), :);
    pxl2 = im2(int64(xyz_d(1)), int64(xyz_d(2)), :);
    
    morphed_im(x(i), y(i), :) = (1-dissolve_frac)*pxl1 + dissolve_frac*pxl2;
end




