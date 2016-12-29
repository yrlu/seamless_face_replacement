% Replace all faces in the video
%   - convert the video into matrix (hxwx3xn_frames)
%   - resize video into 1/2 (faster)
%   - remove unnecessary mouth control points from dlib detection
%   - resize detection landmarks to 1/2
%   - face tracking 
%   - trajectories smoothing
%   - extract face shape features
%   - face episodic matching
%   

% @author Yiren Lu & Dongni Wang
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/23/2016
% 
% @input    src_video_path          mp4 video to be face replaced
%           dst_video_path          mp4 video including the source faces
%           src_landmarks           face landmark detection results of the
%                                   source video
%           dst_landmarks           face landmark detection results of the 
%                                   destination video
%           src_face_idx            source face index
% @output   v_res                   cell array replacement results (0.5hx0.5wx3xn_frames)
function [v_res] = replace_all_faces(src_video_path, dst_video_path, src_landmarks, dst_landmarks, src_face_idx, resizex)
if nargin < 6
    resizex = 2;
end
addpath ./utils
%% preprocess
disp 'preprocess'
tic
src_v_mat = video2mat(src_video_path);
dst_v_mat = video2mat(dst_video_path);

n_src_frames = size(src_v_mat,4);
n_dst_frames = size(dst_v_mat,4);
toc

%% resize video & landmarks
disp 'resizing video and landmarks'
tic 
src_v_mat = src_v_mat(1:resizex:end,1:resizex:end,:,1:n_src_frames);
dst_v_mat = dst_v_mat(1:resizex:end,1:resizex:end,:,:);

src_lmks_out = src_landmarks(1:n_src_frames);
for i = 1:n_src_frames
    for j = 1:numel(src_lmks_out{i})
        src_lmks_out{i}{j} = src_lmks_out{i}{j}/resizex;
        % remove 62-64;
        idx = ones(size(src_lmks_out{i}{j},1),1);
        idx(62:64) = 0;
        src_lmks_out{i}{j} = src_lmks_out{i}{j}(logical(idx),:);
    end
end

dst_lmks_out = dst_landmarks(1:n_dst_frames);
for i = 1:n_dst_frames
    for j = 1:numel(dst_lmks_out{i})
        dst_lmks_out{i}{j} = dst_lmks_out{i}{j}/resizex;
        % remove 62-64;
        idx = ones(size(dst_lmks_out{i}{j},1),1);
        idx(62:64) = 0;
        dst_lmks_out{i}{j} = dst_lmks_out{i}{j}(logical(idx),:);
    end
end
toc

%% face tracking
disp 'face tracking'
tic
src_lmks_track = face_tracking(src_v_mat, src_lmks_out);
dst_lmks_track = face_tracking(dst_v_mat, dst_lmks_out);
toc

%% face landmark trajectories smoothing
disp 'landmark trajectories smoothing'
tic
src_lmks = face_traj_smoother(src_lmks_track,3);
dst_lmks = face_traj_smoother(dst_lmks_track,3);
toc

%% extract face features
disp 'face shape features extraction and episodic matching'
tic
n_feats = 392;
src_face_feat = zeros(n_src_frames, n_feats);
for i = 1:n_src_frames
    % always use [src_face_idx]-th face in the source video
    face = src_lmks{i}{src_face_idx};
    src_face_feat(i,:) = face_shape_feat(face);
end

%% episodic matching
n_dst_faces = numel(dst_lmks{1});
dst_face_feat = zeros(n_dst_frames, n_feats, n_dst_faces);
matches = zeros(n_dst_frames, n_dst_faces);
for j = 1:n_dst_faces
    for i = 1:n_dst_frames
        face = dst_lmks{i}{j};
        dst_face_feat(i,:,j) = face_shape_feat(face);
    end
    matches(:,j) = match_faces_ransac(src_face_feat, dst_face_feat(:,:,j), 12);
end
toc

%% face replacement
disp 'face replacement'
v_res = cell(n_dst_faces,1);
%%
for i = 1:n_dst_frames
    img_dist = uint8(dst_v_mat(:,:,:,i));
    for j = 1:n_dst_faces
        tic
        if matches(i,j) ~= 0
            img_src = uint8(src_v_mat(:,:,:,matches(i,j)));
            face_src = src_lmks{matches(i,j)}{src_face_idx};
            face_dist = dst_lmks{i}{j};
            img_dist = face_replacement(img_src, img_dist, face_src, face_dist);
        end
        disp(sprintf('frame:%d, face:%d', i, j));
        toc
    end
    v_res{i} = img_dist;
end
end