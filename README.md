# TurtleBot3 + Nav2 autonomous navigation (ROS 2 Humble, Gazebo Classic)

A TurtleBot3 Waffle drives itself through three goals in `turtlebot3_world` using the stock
Nav2 stack. A box that is **not on the saved map** is dropped into the corridor Nav2 would
normally use, so the robot has to detect it with its lidar and route around it.

No custom navigation code: Nav2 does the localisation (AMCL), path planning and obstacle
avoidance. `scripts/patrol.py` only sets the start pose and sends goals.

**Demo video (67 s):** [`docs/demo.mp4`](docs/demo.mp4). Terminal top-left, Gazebo bottom-left,
RViz right. The red box is the unmapped obstacle; in RViz it appears in the costmaps once the lidar
sees it.

## Run it

Needs Docker and an X server (tested on Arch Linux, Hyprland/XWayland, AMD iGPU via Mesa).

```bash
docker build -t tb3-nav2 .
./demo.sh            # with the unmapped box
./demo.sh --no-box   # baseline
docker rm -f tb3     # stop
```

Gazebo and RViz open; after about 20 s the robot starts driving. Each goal prints its result
and time.

Running on Ubuntu 22.04 natively instead: install the same apt packages as in the `Dockerfile`,
apply the three `export`/`source` lines it adds to `.bashrc`, then run the commands inside
`demo.sh` without the `docker` wrappers.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | ROS 2 Humble + Nav2 + TurtleBot3 Gazebo packages, plus the Gazebo model-path fix |
| `demo.sh` | Starts the simulation, spawns the box, runs the goals |
| `scripts/patrol.py` | Sets initial pose, sends 3 goals via `nav2_simple_commander`, reports result and time |
| `models/box.sdf` | The unmapped obstacle (0.4 x 0.4 x 0.5 m) |
| `config/nav2_view.rviz` | Nav2's default RViz layout, zoomed out (scale 160 -> 75) so the whole world is visible |

## Results

Goals were checked against the occupancy map first: every goal sits in free space with at
least 0.5 m clearance (the Waffle's radius is about 0.22 m).

| Leg | Baseline | With box (run 1) | With box (run 2) | With box (video) |
|---|---|---|---|---|
| start -> (1.6, 0.5) | 16.9 s | 15.8 s | 22.8 s | 15.8 s |
| -> (0.5, 1.6) | 12.1 s | 12.2 s | 13.8 s | 12.8 s |
| -> (-1.6, -0.5) | 21.4 s | 21.3 s | 21.9 s | 21.1 s |

All 12 goals succeeded. Without the box, the planner's route to the first goal runs along the
corridor at y ≈ 0.52. With the box, it switches to the parallel corridor at y ≈ -0.55. That
corridor is about the same length, which is why leg 1 isn't consistently slower. One box run
took 7 s longer on leg 1, and with 3 samples I can't say why.

## Problems hit

1. **Gazebo hung, robot never spawned.** I had set `GAZEBO_MODEL_PATH` in the Dockerfile,
   which *replaced* Gazebo's default path, so it couldn't find its own `ground_plane`/`sun`
   models and fell back to the online model database, which hung. Symptom: `/odom` *appeared*
   in `ros2 topic list` (Nav2 subscribes to it), but `ros2 topic info /odom` showed 0 publishers.
2. **Robot spawned into an empty world.** After removing that line: `Unable to find
   uri[model://turtlebot3_world]`. Lidar returned 360 out of 360 readings as `inf`. Nav2's Humble
   launch file starts `gzserver` directly, so `turtlebot3_gazebo`'s `package.xml` model export is
   never read. Fix: source Gazebo's `setup.sh`, then *append* the TurtleBot3 models folder.
   Also blanked `GAZEBO_MODEL_DATABASE_URI` so a missing model fails fast instead of hanging.
3. **Ignored as harmless:** an RViz GLSL shader link error and an `amdgpu ... bad things may
   happen` warning. Both windows render correctly (checked by screenshot).

## Not done

- No Nav2 parameter tuning. Everything runs on `nav2_bringup`'s default `nav2_params.yaml`.
- Only one world (`turtlebot3_world`) and 1–3 runs per condition: not enough for timing claims.
- The box is placed before the run starts, not while the robot is moving.
- Gazebo Classic is end-of-life. The current pairing is ROS 2 Jazzy + Gazebo Harmonic. I chose
  Humble + Classic because it is the most documented TurtleBot3/Nav2 path and the deadline was
  3 days.
