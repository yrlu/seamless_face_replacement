function [morphed_im] = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)
% Author: Max Lu
% Date: 10/17/2016
% luyiren@seas.upenn.edu
%
% Inputs:   im_source:   Hs x Ws x 3 matrix representing the source image
%           a1_x, ax_x, ay_x, w_x:  the parameters solved when doing
%                       est_tps in the x direction
%           a1_y, ax_y, ay_y, w_y:  the parameters solved when doing
%                       est_tps in the y direction
%           ctr_pts:    N x 2 matrix, each row representing corresponding
%                       point position (x, y) in target image
%           sz:         1 x 2 vector representing the target image size 
%                       (Hs, Ws)
% Output:   morphed_im: Ht x Wt x 3 matrix representing the morphed image

% [a1_x,ax_x,ay_x,w_x] = est_tps(im1_pts, im2_pts(:,1));
% [a1_y,ax_y,ay_y,w_y] = est_tps(im1_pts, im2_pts(:,2));

function [u] = U(r) 
u = -(r.^2.*log(r.^2));
u(isnan(u)) = 0;
end

% compute the kernal first


fx = @(x, y) a1_x + ax_x * x + ay_x * y + sum(U(sqrt(sum(bsxfun(@minus, ctr_pts, [x y]).^2,2))).*w_x);
fy = @(x, y) a1_y + ax_y * x + ay_y * y + sum(U(sqrt(sum(bsxfun(@minus, ctr_pts, [x y]).^2,2))).*w_y);

morphed_im = zeros(sz(1), sz(2), 3);
[x y] = ind2sub([size(morphed_im,1), size(morphed_im,2)],1:size(morphed_im,1)*size(morphed_im,2));
x = x';
y = y';


k = zeros(numel(x), size(ctr_pts,1));
for i = 1:size(ctr_pts,1)
    k(:,i) = U(sqrt(sum(bsxfun(@minus, [x y], ctr_pts(i,:)).^2,2)));
end

% Actually this vectorization makes it slower: 
% k = reshape(U(sqrt(sum( bsxfun(@minus, repmat([x,y], [1,1,size(ctr_pts,1)]), reshape(ctr_pts', [1,2,size(ctr_pts,1)])).^2 ,2))), [numel(x), size(ctr_pts,1)]);

src_xy = int64([a1_x + ax_x * x + ay_x * y + k * w_x, a1_y + ax_y * x + ay_y * y + k * w_y]);
src_xy(src_xy(:,1) > size(im_source,1),1) = size(im_source,1);
src_xy(src_xy(:,2) > size(im_source,2),2) = size(im_source,2);
src_xy(src_xy(:,1) < 1,1) = 1;
src_xy(src_xy(:,2) < 1,2) = 1;

morphed_im((y-1).*sz(1)+x) = im_source((src_xy(:,2)-1).*sz(1)+src_xy(:,1));
morphed_im((y-1).*sz(1)+x+sz(1)*sz(2)) = im_source((src_xy(:,2)-1).*sz(1)+src_xy(:,1)+sz(1)*sz(2));
morphed_im((y-1).*sz(1)+x+sz(1)*sz(2)*2) = im_source((src_xy(:,2)-1).*sz(1)+src_xy(:,1)+sz(1)*sz(2)*2);

end
