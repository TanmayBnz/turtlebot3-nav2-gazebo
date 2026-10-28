#!/usr/bin/env bash
# Full demo: Gazebo + Nav2 + RViz, an unmapped box in the robot's path, then three autonomous goals.
# Usage: ./demo.sh          (with the box)
#        ./demo.sh --no-box (baseline)
# Stop with: docker rm -f tb3
set -e
cd "$(dirname "$0")"
xhost +local:docker >/dev/null

docker rm -f tb3 >/dev/null 2>&1 || true
docker run -d --name tb3 --net=host --ipc=host \
  -e DISPLAY="$DISPLAY" -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/dri \
  -v "$PWD":/ws tb3-nav2 \
  bash -ic 'ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False' >/dev/null

echo "waiting for Gazebo to spawn the robot..."
timeout 180 bash -c 'until docker logs tb3 2>&1 | grep -q "Spawn status"; do sleep 2; done'

if [ "$1" != "--no-box" ]; then
  # Sits in the corridor Nav2 would otherwise use for the first goal (see README).
  docker exec tb3 bash -ic 'ros2 run gazebo_ros spawn_entity.py -entity surprise_box \
    -file /ws/models/box.sdf -x -0.55 -y 0.55' 2>&1 | grep "Spawn status"
fi

docker exec -it tb3 bash -ic 'python3 /ws/scripts/patrol.py'
