% @author Yiren Lu
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/20/2016
% 
% @input    src_face_feats      mx[dim feat] source faces features
%           dist_face_feats     nx[dim feat] distination faces features
%           episode_length      unit length of matching
% @ouptut   match               nx1  matched indices from src to dist faces
function [match] = match_faces_ransac(src_face_feats, dist_face_feats, episode_length)

m = size(src_face_feats,1);
n = size(dist_face_feats,1);
match = zeros(n,1);
kdtree = KDTreeSearcher(src_face_feats(1:end-episode_length,:));

    function find_match(i, episode_len)
        % Here we use the best match for the starting frame to match
        % episodes. We can also use RANSAC as presented. In practice,
        % matching starting frame is faster and got us good enough results
        feat = dist_face_feats(i,:);
        [idx D] = knnsearch(kdtree, feat, 'K', 1);
        % here we only match the first frame
        match(i:i+episode_len-1) = [idx:idx+episode_len-1];
        
        
        % comment above and uncomment the following to use RANSAC for 
        % episodic matching
%         best_score = 0;
%         for t = 1:1000
%             r = randi([1,m-episode_len]);
%             score = sum(sum((dist_face_feats(i:i+episode_len-1,:) - src_face_feats(r:r+episode_len-1,:)).^2,2)/episode_len < 1000);
%             if score > best_score
%                 best_score = score;
%                 match(i:i+episode_len-1) = [r:r+episode_len-1];
%             end
%         end
    end

for i = 1:episode_length:n-episode_length+1
    % [i, i+episode_length-1];
    find_match(i, episode_length);
end
last_episode = mod(n, episode_length);
if last_episode ~= 0
find_match(n-last_episode+1, last_episode);
end
end