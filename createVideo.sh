#!/bin/bash
ffmpeg -framerate 30 -y -i outputPNGS/output%d.png -crf 0 -c:v libx264 -preset veryslow -vf scale=370:370:flags=neighbor,format=yuv420p ./duffelbag_new_out.mp4

sleep 1

#RUN 0
ffmpeg -y -i duffelbag_new_out.mp4 -vf "scale=370:-1,pad=800:ih:(ow-iw)/2:0:black" duffbag_padded.mp4

sleep 1

#RUN 1
ffmpeg -y -i animation.gif -i duffbag_padded.mp4 -filter_complex "[0:v]fps=30,setpts=(100/3/30)*PTS[v0]; [1:v]fps=30,setpts=PTS[v1]; [v0][v1]vstack=inputs=2,drawtext=text=Frame %{n}:x=10:y=10:fontcolor=red:fontsize=24" -c:a copy output.mp4

sleep 1


#RUN 2
ffmpeg -y -i 'output.mp4' -i 'boxes.mp4' -filter_complex '[0:v]fps=30,setpts=PTS,scale=-1:970[v0]; [1:v]fps=30,setpts=PTS,scale=-1:970[v1]; [v0][v1]hstack=inputs=2' -c:a copy output2.mp4

#FOREIGN ITEM
ffmpeg -y -i 'pen.png' -i 'foreign_object_masked.jpg' -filter_complex "
  [0:v]scale=600:-1[img1]; 
  [1:v]scale=600:-1[img2]; 
  [img1][img2]vstack=inputs=2[stacked]; 
  [stacked]drawtext=text='Foreign Item':x=10:y=10:fontcolor=red:fontsize=24:box=1:boxcolor=white@1:boxborderw=5" \
  -frames:v 1 -update 1 foreign_item_stack.png


ffmpeg -y -i 'output2.mp4' -i 'foreign_item_stack.png' -filter_complex '[0:v]fps=30[v0]; [1:v]scale=-1:970[v1]; [v1][v0]hstack=inputs=2' -c:a copy result.mp4