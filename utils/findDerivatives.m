function [J, theta, Jx, Jy] = findDerivatives(I, Gx, Gy)
% Author: Max Lu
% Date: 09/18/2016
%
% Inputs:   I      H*W matrix representing grayscale image
%           Gx, Gy Gaussian Filters
% Outputs:  J      H*W matrix representing the magnitude of derivatives
%           theta  H*W matrix representing the orientation of derivatives
%           Jx, Jy H*W matrix representing the derivatives along x/y-axis


[dx,dy] = gradient(conv2(Gx, Gy));

Jx = conv2(double(I), dx, 'same');
Jy = conv2(double(I), dy, 'same');
theta = atan2(Jy, Jx);
J = sqrt(Jx.*Jx + Jy.*Jy);
