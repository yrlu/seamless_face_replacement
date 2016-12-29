% Face landmarks trajectories smoother
%   - guassian filter applied to the face trajectories
% 
% @author Yiren Lu
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/21/2016
% 
% @input    faces        faces landmark information (after tracking)
%           window_size  window_size for smoother, default 3 
% @output   faces_res    smoothed results of faces landmark trajectories
function [faces_res] = face_traj_smoother(faces, window_size)
if nargin < 2
    window_size = 3;
end
n_faces = numel(faces{1});
n_frames = numel(faces);
n_landmark = size(faces{1}{1},1);

% convert the face trajectories into a matrix 
% [#landmarks x 2 x #faces x #frames]
faces_mat = zeros(n_landmark, 2, n_faces, n_frames);
detection_failed = zeros(n_frames,1);
for i = 1:n_faces
    for j = 1:n_frames
        if size(faces{j}{i},1) > 0
            faces_mat(:,:,i, j) = double(faces{j}{i});
        else
            detection_failed(j) = 1;
        end
    end
end

dist = normpdf([-(window_size-1)/2:(window_size-1)/2], 0, (window_size-1)/2);
dist = dist/sum(dist);
dist = reshape(dist, [1, 1, 1, window_size]);
dist = repmat(dist, [n_landmark, 2, 1, 1]);

% smoothing
for i = 1:n_faces
    for j = (window_size-1)/2+1:n_frames-(window_size-1)/2
        if sum(detection_failed(j-(window_size-1)/2: j+(window_size-1)/2)) == 0
            faces_mat(:,:,i,j) = sum(faces_mat(:,:,i, j-(window_size-1)/2: j+(window_size-1)/2).*dist,4);
        end
%         faces_mat(:,:,i,j) = mean(faces_mat(:,:,i, j-(window_size-1)/2: j+(window_size-1)/2),4);
    end
end

% fill points back to faces
for i = 1:n_faces
    for j = (window_size-1)/2+1:n_frames-(window_size-1)/2
        faces{j}{i} = faces_mat(:,:,i, j);
    end
end
faces_res = faces;
end