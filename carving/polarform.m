function t = polarform(rmin, rmax, nr, nw)
% LOGTFORM makes a log-polar transform structure for imtransform
%     T = POLARFORM(RMIN, RMAX, NR, NW) returns the transform structure for
%     a system with minimum ring radius RMIN, maximum ring radius RMAX, NR
%     rings and NR wedges. 
%
% See also POLARSAMPLE, POLARSBACK

% Dongni Wang @ Dec 21
k = (nr-1) / (rmax/rmin);
tdata = struct('rmin', rmin, 'rmax', rmax, 'nr', nr, 'nw', nw, 'k', k);
t = maketform('custom', 2, 2, @contorth, @rthtocon, tdata);
end

function x = contorth(u, t)
% Conventional to log-polar. See maketform.
td = t.tdata;
[th, p] = cart2pol(u(:,1), u(:, 2));
p(~p) = td.rmin/2;            % Omit centre point
x = [td.k * (p/td.rmin),  td.nw*mod(th/(2*pi), 1)];
end

function u = rthtocon(x, t)
% Log-polar to conventional. See maketform.
td = t.tdata;
p = td.rmin * (x(:, 1)/td.k);
th = (2*pi/td.nw) * x(:, 2);
[x, y] = pol2cart(th, p);
u = [x, y];
end

