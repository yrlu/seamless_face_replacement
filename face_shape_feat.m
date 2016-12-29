% Extract shape histogram features from face landmark
% 
% @author Yiren Lu
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/20/2016

% @input    face    face landmark struct
% @output   feats   features extracted
function [feats] = face_shape_feat(face)

if size(face,1) == 0
    % detection and tracking both failed
    feats = zeros(392,1);
    return 
end

center = mean(face);
points = double(face);
n_p = size(points,1);
feats = bsxfun(@minus, points, center);
% feats = feats(:)/sum(feats(:));

% convert the points into log-polar coordinate
p = log(sqrt(sum(feats.^2,2)));
theta = atan(feats(:,2)./feats(:,1));
eyes_offset = points(21,:) - points(64,:);
theta_offset = atan(eyes_offset(2)/eyes_offset(1));

theta = theta - theta_offset;
% scale invariant
feats_p = zeros(n_p, n_p);
for i = 1:n_p
    for j = 1:n_p
        feats_p(i,j) = p(i) - p(j);
    end
end
feats_p = feats_p/max(p);

% rotation invariant
feats_theta = zeros(n_p, n_p);
for i = 1:n_p
    for j = 1:n_p
        feats_theta(i,j) = theta(i) - theta(j);
    end
end
% histogram voting
Xedges = [-0.7:0.05:0.7];
Yedges = [-3.5:0.5:3.5];
[feats] = histcounts2(feats_p,feats_theta,Xedges, Yedges);
% blur histogram to make the features robust
feats = feats(:);
end