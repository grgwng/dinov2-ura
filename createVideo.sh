
# Check for 2 arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_video.mp4> <foreign_object.png>"
    exit 1
fi

INPUT_VIDEO="$1"
FOREIGN_OBJECT="$2"

#!/bin/bash
ffmpeg -framerate 30 -y -i outputPNGS/output%d.png -crf 0 -c:v libx264 -preset veryslow -vf scale=370:370:flags=neighbor,format=yuv420p ./dinov2_video.mp4

sleep 1

#RUN 0
ffmpeg -y -i dinov2_video.mp4 -vf "scale=370:-1,pad=800:ih:(ow-iw)/2:0:black" dinov2_video_padded.mp4

sleep 1

#RUN 1
ffmpeg -y -i animation.gif -i dinov2_video_padded.mp4 -filter_complex "[0:v]fps=30,setpts=(100/3/30)*PTS[v0]; [1:v]fps=30,setpts=PTS[v1]; [v0][v1]vstack=inputs=2,drawtext=text=Frame %{n}:x=10:y=10:fontcolor=red:fontsize=24" -c:a copy output.mp4

sleep 1


#RUN 2
ffmpeg -y -i 'output.mp4' -i "$INPUT_VIDEO" -filter_complex '[0:v]fps=30,setpts=PTS,scale=-1:970[v0]; [1:v]fps=30,setpts=PTS,scale=-1:970[v1]; [v0][v1]hstack=inputs=2' -c:a copy output2.mp4

#FOREIGN ITEM
ffmpeg -y -i "$FOREIGN_OBJECT" -i 'foreign_object_masked.png' -filter_complex "
  [0:v]scale=600:-1[img1]; 
  [1:v]scale=600:-1[img2]; 
  [img1][img2]vstack=inputs=2[stacked]; 
  [stacked]drawtext=text='Foreign Item':x=10:y=10:fontcolor=red:fontsize=24:box=1:boxcolor=white@1:boxborderw=5" \
  -frames:v 1 -update 1 foreign_item_stack.png


ffmpeg -y -i 'output2.mp4' -i 'foreign_item_stack.png' -filter_complex '[0:v]fps=30[v0]; [1:v]scale=-1:970[v1]; [v1][v0]hstack=inputs=2' -c:a copy result.mp4

sleep 1

rm dinov2_video.mp4 dinov2_video_padded.mp4 output.mp4  output2.mp4 foreign_item_stack.png