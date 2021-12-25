#!/bin/bash
#######################################################################################################################
# Inferring Temporal Logic Specifications for Robot-Assisted Feeding in Social Dining Settings
#
# Jan Ondras (janko@cs.cornell.edu, jo951030@gmail.com)
# Project for Program Synthesis (CS 6172)
# Cornell University, Fall 2021
#######################################################################################################################
#######################################################################################################################
# Extract vision features from the dataset using OpenFace
# (optionally, also generate tracked videos by OpenFace)
#
#     Video files naming convention: {session_id}_{participant_id}.mp4
#         session_id:     2 digits, starting from 01 (00 was pilot study)
#         participant_id: 1 digit,  starting from 1 (max 3)
#######################################################################################################################


# Session id to start with (when running the extraction in parallel)
start_session_id=0

input_dir=~/projects/social-dining/data/original/video
output_dir=~/projects/social-dining/data/processed/vision_openface_features

echo "Input path: ${input_dir}"
echo "Output path: ${output_dir}"
echo ""

openface_dir=~/tools/OpenFace/build/bin
cd $openface_dir
cnt=0

for f in ${input_dir}/*.mp4
do
    filename=$(basename -- $f)
    session_id=(${filename:0:2})
    echo $session_id

    if [ $session_id -ge $start_session_id ]
    then
        cnt=$((cnt+1))

        start_time=$(date +%s)

        ./FeatureExtraction -f $f -out_dir ${output_dir} -2Dfp -3Dfp -pdmparams -pose -aus -gaze 
        # To get tracked videos
        # ./FeatureExtraction -f $f -out_dir ${output_dir} -tracked

        end_time=$(($(date +%s)-start_time))

        echo "Filepath, Session ID, Filename, Time taken (seconds):"
        echo $f","$session_id","$filename","$end_time
        echo ""
    fi

done

echo ""
echo "Extracted features from ${cnt} videos."
