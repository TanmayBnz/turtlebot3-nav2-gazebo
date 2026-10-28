FROM osrf/ros:humble-desktop

RUN apt-get update && apt-get install -y --no-install-recommends \
      ros-humble-navigation2 \
      ros-humble-nav2-bringup \
      ros-humble-nav2-simple-commander \
      ros-humble-turtlebot3-gazebo \
      ros-humble-turtlebot3-navigation2 \
    && rm -rf /var/lib/apt/lists/*

ENV TURTLEBOT3_MODEL=waffle

# Gazebo's setup.sh adds its built-in models (ground_plane, sun). nav2_bringup starts gzserver
# directly, so turtlebot3_gazebo's package.xml model export is never read; append its models by hand.
# Blanking the model database URI makes a missing model fail fast instead of hanging on an online lookup.
RUN printf '%s\n' \
      'source /opt/ros/humble/setup.bash' \
      'source /usr/share/gazebo/setup.sh' \
      'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/opt/ros/humble/share/turtlebot3_gazebo/models' \
      'export GAZEBO_MODEL_DATABASE_URI=' >> /root/.bashrc
WORKDIR /ws
