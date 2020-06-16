#!/bin/bash

echo $1
OUTVIDEOPATH=$1
echo $OUTVIDEOPATH
OUTVIDEOPATH=${OUTVIDEOPATH/%mkv/mov}
echo $OUTVIDEOPATH
OUTVIDEOPATH=${OUTVIDEOPATH/Input/Processed}
echo $OUTVIDEOPATH

NumBuffers=""
if [[ -n "$2" ]]; then
NumBuffers="num-buffers=$2"
echo $NumBuffers
fi 

GST_DEBUG="*:0" gst-launch-1.0 -v filesrc location="$1" $NumBuffers ! tee name=srcT  \
qtmux name=outMux ! queue ! filesink location="$OUTVIDEOPATH" sync=true \
srcT. ! queue ! matroskademux ! h264parse ! nvv4l2decoder ! nvv4l2h265enc control-rate=1 bitrate=2000000 EnableTwopassCBR=1 preset-level=4 maxperf-enable=1 EnableMVBufferMeta=1 ! h265parse ! outMux. \
srcT. ! queue ! matroskademux ! queue ! dcaparse ! queue ! dtsdec ! audioresample ! audioconvert ! audio/x-raw,channels=2 ! audioresample ! queue ! avenc_aac bitrate=192000 perfect-timestamp=1 ! queue ! aacparse ! outMux.
