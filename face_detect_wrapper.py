import sys
import os
import dlib
import glob
import cv2
import numpy as np
from skimage import io
import scipy.io as sio

if len(sys.argv) != 3:
    "./face_detect_wrapper.py detector_path video_name"
    "path: /Users/dongniwang/Desktop/CIS_581/project4/project4_libs/dlib/python_examples/shape_predictor_68_face_landmarks.dat"
    exit()

predictor_path = sys.argv[1]
video_pre = sys.argv[2]
video_name = sys.argv[2]+'.mp4'

vidcap = cv2.VideoCapture(video_name)
success,img = vidcap.read()
frame_num = 0

detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(predictor_path)

while success:
    frame_num += 1
    # dlib.hit_enter_to_continue()
    success,img = vidcap.read()
frame_cell = np.zeros((frame_num,), dtype=np.object)

vidcap = cv2.VideoCapture(video_name)
success,img = vidcap.read()
count = 0

while success: 
    print("Processing frame: {}".format(count))
    dets = detector(img, 1)
    faces = np.zeros((len(dets),), dtype=np.object)
    for k, d in enumerate(dets):
        shape = predictor(img, d)
        vec = np.empty([shape.num_parts, 2], dtype = int)
        for b in xrange(shape.num_parts):
            vec[b][0] = shape.part(b).x
            vec[b][1] = shape.part(b).y
        faces[k] = vec
    frame_cell[count]= faces
    count += 1
    # dlib.hit_enter_to_continue()
    success,img = vidcap.read()

sio.savemat(video_pre+'_out.mat', {video_pre:frame_cell})
