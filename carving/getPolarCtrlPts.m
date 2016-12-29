function [th_r, theta_d] = getPolarCtrlPts(contour_pts, noseX, noseY, nr, nw, rmax, rmin)
%[theta, rho] = cart2pol(coord_x, coord_y);
x_dst = (contour_pts(:,1) - noseX);
y_dst = (contour_pts(:,2) - noseY);
%rho = sqrt(x_dst.^2 + x_dst.^2);
%p = atan(y_dst./x_dst);
[th, p] = cart2pol(x_dst, y_dst);
K = (nr-1)/ log(rmax/rmin);
% 2 K = (nr-1)/ (rmax/rmin);
th_r = K * log(p);
% 2 th_r = K * (p);
p_d = nw*mod(th/(2*pi),1); 
%rad2deg(p);
th_r = uint16(th_r);
theta_d = uint16(p_d);
% 
%     Ring number:      R = K * log( P / RMIN )
% 
%         where         K = (NR - 1) / log( RMAX / RMIN )
% 
%     Wedge number:     W = NW * T / (2 * PI)
end