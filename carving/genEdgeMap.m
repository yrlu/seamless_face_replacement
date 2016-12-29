function J = genEdgeMap(I)
% Construct 2D Gaussian filter
I = rgb2gray(I);
Gx = [0, 0.0001, 0.0044, 0.0540, 0.2420, 0.3989, ...
    0.2420, 0.0540, 0.0044, 0.0001, 0.0000];
Gy = Gx';
I = double(I);
% filter out noise and compute derivative of gaussian
dx = gradient(Gx);
dy = gradient(Gy);
Jx = conv2(I, dx, 'same');
Jy = conv2(I, dy, 'same');
% compute magnitude
J = sqrt(Jx.*Jx+Jy.*Jy);
end
