% Convert video file to mat format
% @author Yiren Lu
% @date 12/17/2016
% 
% @input 
%           file_path:  video file path
% @output
%           v_mat:      frame_height x frame_width x 3 x num_frames matrix
%                       representing the video [uint8 0-255]
function [v_mat] = video2mat(file_path)

vidObj = VideoReader(file_path);
f = read(vidObj, Inf);
size_frame = size(f);
n_frames = vidObj.NumberOfFrames;
v_mat = zeros(size_frame(1), size_frame(2), size_frame(3), n_frames);
videoFileReader = vision.VideoFileReader(file_path);
j = 1;
while ~isDone(videoFileReader)
    videoFrame = step(videoFileReader);
    v_mat(:,:,:,j) = uint8(videoFrame*255);
    j = j + 1;
end

end