% Face tracking with KLT
%
% @author Yiren Lu
% @email luyiren [at] seas [dot] upenn [dot] edu
% @date 12/21/2016
% 
% @input    v_mat       hxwx3x[#frames] video
%           faces       detected faces landmarks points
% @output   faces_res   tracked faces landmarks
function [faces_res] = face_tracking(v_mat, faces)
tracking_frames = 5;
faces_res = faces;
n_frames = numel(faces);
last_detected = ones(numel(faces{1}));
for i = 1:numel(faces{1})
    img = uint8(v_mat(:,:,:,1));
    pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
    points = double(faces{1}{i});
    initialize(pointTracker, points, img);
    for j = 2:n_frames
        img = uint8(v_mat(:,:,:,j));
        flag = 0;
        for k = 1:numel(faces{j})
%             norm(mean(faces{j}{k}) - mean(faces_res{last_detected(i)}{i}))
            if norm(mean(faces{j}{k}) - mean(faces_res{last_detected(i)}{i})) < 30
                % found tracked face
                faces_res{j}{i} = faces{j}{k};
                last_detected(i) = j;
                flag = 1;
                points = double(faces_res{j}{i});
                step(pointTracker, img);
                points(points<1) = 1;
                setPoints(pointTracker, points);
                break;
            end
        end
        if flag == 0 % face is not found
            [points, isFound] = step(pointTracker, img);
            points(points<1) = 1;
            setPoints(pointTracker, points);
            if j - last_detected(i) < tracking_frames
                faces_res{j}{i} = points;
            else
                faces_res{j}{i} = [];
            end
        end
    end
end

end