load('clips/clip1_faces_out.mat');
load('Proj4_Test/easy/easy1_faces_out.mat');

%% replace faces
v_res = replace_all_faces('clips/clip1.mp4', 'Proj4_Test/easy/easy1.mp4', clip1, easy1, 1, 2);

%% write to video
writer = VideoWriter('test_easy1_all_faces.avi', 'Uncompressed AVI');
writer.FrameRate = 20;
open(writer);
for i = 1:numel(v_res)
    i
    writeVideo(writer,v_res{i});
end
close(writer);

