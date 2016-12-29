function rm_arr = getPolarCarve(log_arr, nr, nw, polar_ctrls)
% output: rm_arr: logical, polar space carve-route
% inputs: log_arr
%         start and end radius 

% e = genEngMap(log_arr);
% e = genEdgeMap(log_arr);
e = log_arr;

% we enforce the choose the of radius by setting other options very expensive.
% starting and ending at degree 0
[~, p_index] = min(polar_ctrls(:,2));
r_starter = polar_ctrls(p_index,1);
r_temp = e(1,r_starter);
e(1,:) = Inf;
e(1,r_starter) = r_temp;

%also enforce forhead chosen:
r_end = nr-1;
r_temp = e(270,r_end);
e(270,:) = Inf;
e(270,r_end) = r_temp;

for i = 1:size(polar_ctrls, 1)
    p_deg = polar_ctrls(i, 2);
    if p_deg == 0
        p_deg = 360;
    end
    r_chosen = polar_ctrls(i, 1);
    r_temp = e(p_deg, r_chosen);
    e(p_deg,:) = nw;
    e(p_deg, r_chosen) = r_temp;
end

[~, Tbx] = cumMinEngVer(e);
rm_arr = zeros(nw, nr);
rm_arr(1,r_starter) = 1;
rm_arr(end, r_starter) = 1;
path = r_starter;
for i = nw-1:-1:1
    path = Tbx(i+1, int64(path));
    rm_arr(i,path) = 1;
end
end
