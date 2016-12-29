clear;clc;
sample_files_mat = {'Proj4_Simple/easy/easy1.mat', 'Proj4_Simple/easy/easy2.mat', ...
    'Proj4_Simple/medium/medium1.mat', ...
    'Proj4_Simple/hard/hard1.mat'};

test_files_mat = {'Proj4_Test/easy/easy1.mat', 'Proj4_Test/easy/easy2.mat', 'Proj4_Test/easy/easy3.mat', 'Proj4_Test/easy/easy4.mat', ...
    'Proj4_Test/medium/medium1.mat', 'Proj4_Test/medium/medium2.mat', 'Proj4_Test/medium/medium3.mat', 'Proj4_Test/medium/medium4.mat', ...
    'Proj4_Test/hard/hard1.mat', 'Proj4_Test/hard/hard2.mat', 'Proj4_Test/hard/hard3.mat'};

% load('sample_out_landmarks.mat');
% load('test_out_landmarks.mat');

clip_files = {'clips/clip1.mp4', 'clips/clip2.mp4', 'clips/clip3.mp4'};
clip_files_mat = {'clips/clip1.mat', 'clips/clip2.mat', 'clips/clip3.mat'};

load('clips/clip1_faces_out.mat');
load('clips/clip2_faces_out.mat');
load('clips/clip3_faces_out.mat');

load('Proj4_Test/easy/easy1_faces_out.mat');
load('Proj4_Test/easy/easy2_faces_out.mat');
load('Proj4_Test/easy/easy3_faces_out.mat');
load('Proj4_Test/easy/easy4_faces_out.mat');


load('Proj4_Test/medium/medium1_faces_out.mat');
load('Proj4_Test/medium/medium2_faces_out.mat');
load('Proj4_Test/medium/medium3_faces_out.mat');
load('Proj4_Test/medium/medium4_faces_out.mat');

load('Proj4_Test/hard/hard1_faces_out.mat');
load('Proj4_Test/hard/hard2_faces_out.mat');
load('Proj4_Test/hard/hard3_faces_out.mat');

addpath ./utils

%%
v = load(clip_files_mat{2});
n_frames = 200;
v.v_mat = v.v_mat(1:2:end,1:2:end,:,1:n_frames);
lmks_trump_out = clip2(1:n_frames);

%% resize
for i = 1:numel(lmks_trump_out)
    for j = 1:numel(lmks_trump_out{i})
        lmks_trump_out{i}{j} = lmks_trump_out{i}{j}/2;
        % remove 62-64;
        idx = ones(size(lmks_trump_out{i}{j},1),1);
        idx(62:64) = 0;
        lmks_trump_out{i}{j} = lmks_trump_out{i}{j}(logical(idx),:);
    end
end

%% face tracking
lmks_track = face_tracking(v.v_mat(:,:,:,1:n_frames), lmks_trump_out);

%% face trajectories smoothing
lmks_trump = face_traj_smoother(lmks_track,3);

%% extract face features
% compute face descriptors
% 
% n_feats = 166;
n_feats = 392;
trump_face_feat = zeros(n_frames, n_feats);
for i = 1:n_frames
    i
    face = lmks_trump{i}{1};
    trump_face_feat(i,:) = face_shape_feat(face);
end


%% visualization
for i = 1:n_frames
    img = uint8(v.v_mat(:,:,:,i));
    imshow(img); hold on;
    faces = lmks_trump{i};
    for j = 1:1%numel(faces)
        face = faces{j};
        plot(face(:,1),face(:,2),'r.','MarkerSize',20);
    end
    hold off;
    drawnow;
end

%%
v2 = load(test_files_mat{11});
v2.v_mat = v2.v_mat(1:2:end,1:2:end,:,:);
n_frames_easy1 = size(v2.v_mat,4);
lmks_easy1_out = hard3(1:n_frames_easy1);

%% resize
for i = 1:numel(lmks_easy1_out)
    for j = 1:numel(lmks_easy1_out{i})
        lmks_easy1_out{i}{j} = lmks_easy1_out{i}{j}/2;
        idx = ones(size(lmks_easy1_out{i}{j},1),1);
        idx(62:64) = 0;
        lmks_easy1_out{i}{j} = lmks_easy1_out{i}{j}(logical(idx),:);
    end
end


%% face tracking
lmks_easy1_track = face_tracking(v.v_mat, lmks_easy1_out);

%% face trajectories smoothing
lmks_easy1 = face_traj_smoother(lmks_easy1_track,3);

%% extract face features
% compute face descriptors
% 
% n_feats = 166;
n_feats = 392;
test_face_feat = zeros(n_frames_easy1, n_feats);
for i = 1:n_frames_easy1
    i
    face = lmks_easy1{i}{1};
    test_face_feat(i,:) = face_shape_feat(face);
end

%% visualization
for i = 1:n_frames
    img = uint8(v2.v_mat(:,:,:,i));
    imshow(img); hold on;
    faces = lmks_easy1{i};
    for j = 1:numel(faces)
        face = faces{j};
        plot(face(:,1),face(:,2),'r.','MarkerSize',20);
    end
    hold off;
    drawnow;
end


%%
tic
match = match_faces_ransac(trump_face_feat, test_face_feat,12);
toc

%%
res = cell(n_frames_easy1,1);
%%
for i = 1:n_frames_easy1
    i
    tic
    img_src = uint8(v.v_mat(:,:,:,match(i)));
    img_dist = uint8(v2.v_mat(:,:,:,i));
    face_src = lmks_trump{match(i)}{1};
    face_dist = lmks_easy1{i}{1};
    
    img_res = face_replacement(img_src, img_dist, face_src, face_dist);
    res{i} = img_res;
    toc
end


%%
for i = 1:n_frames_easy1
    imshow(res{i});
    drawnow;
end

%%
writer = VideoWriter('test_hard3_full.avi', ...
                        'Uncompressed AVI');
writer.FrameRate = 20;
open(writer);
for i = 1:numel(res)
    i
    writeVideo(writer,res{i});
end
close(writer);




%%
v_res = replace_all_faces('clips/clip1.mp4', 'Proj4_Test/easy/easy1.mp4', clip1, easy1, 1, 2);


%%

src_video_path = 'clips/clip1.mp4';
dst_video_path = 'Proj4_Test/easy/easy1.mp4';
src_landmarks = clip1;
dst_landmarks = easy1;
src_face_idx = 1;

addpath ./utils
%% preprocess
disp 'preprocess'
tic
src_v_mat = video2mat(src_video_path);
dst_v_mat = video2mat(dst_video_path);

% n_src_frames = size(src_v_mat,4);
n_src_frames = 450;
n_dst_frames = size(dst_v_mat,4);
toc

%% resize video & landmarks
disp 'resizing video and landmarks'
tic 
src_v_mat = src_v_mat(1:2:end,1:2:end,:,1:n_src_frames);
dst_v_mat = dst_v_mat(1:2:end,1:2:end,:,:);

src_lmks_out = src_landmarks(1:n_src_frames);
for i = 1:n_src_frames
    for j = 1:numel(src_lmks_out{i})
        src_lmks_out{i}{j} = src_lmks_out{i}{j}/2;
        % remove 62-64;
        idx = ones(size(src_lmks_out{i}{j},1),1);
        idx(62:64) = 0;
        src_lmks_out{i}{j} = src_lmks_out{i}{j}(logical(idx),:);
    end
end

dst_lmks_out = dst_landmarks(1:n_dst_frames);
for i = 1:n_dst_frames
    for j = 1:numel(dst_lmks_out{i})
        dst_lmks_out{i}{j} = dst_lmks_out{i}{j}/2;
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

%%
for i = 1:numel(v_res)
    imshow(v_res{i});
end