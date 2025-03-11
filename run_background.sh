cd $PWD
ps aux | grep './track.sh' | grep -v grep | awk '{print $2}' | xargs -r kill -9
nohup ./track.sh >> app.log 2>&1 &