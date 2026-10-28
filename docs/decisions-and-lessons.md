# Decisions & Lessons

## 2026-10-28: Simulation set up and working end to end

**What changed:** Built a self-contained simulation in which a small robot drives itself to
three locations and gets around an obstacle that isn't on its map. All 9 test goals succeeded
(3 runs x 3 goals).

**Decisions**
- **Ran everything in a container (Docker) instead of installing on this laptop.** The robot
  software officially supports only Ubuntu, and this machine runs Arch Linux. A container gives
  an Ubuntu environment without changing the laptop, and the recipe file is also the setup guide
  reviewers can rerun.
- **Picked the older, best-documented software versions (ROS 2 Humble with Gazebo Classic)
  over the newest ones.** With a 3-day deadline, a well-documented path was worth more than
  being current. The trade-off: Gazebo Classic is no longer supported, so a longer-lived project
  should move to the newer pairing.
- **Added an obstacle the robot's map doesn't contain.** Driving around obstacles already on
  the map only shows route planning. An unknown box shows the robot actually reacting to what its
  sensor sees, which is what the assignment asks for.

**Lessons**
- A data channel can show up in the list even when nothing is sending on it, because listeners
  register it too. "It's listed" isn't proof it's working: check that something is actually
  publishing to it.
- My first fix for a setup problem caused the next one. The setting I added was needed, but
  written in a way that wiped out the defaults. Add to defaults rather than replacing them.
- When the obstacle test first showed no change in travel time, it looked like it proved
  nothing. Checking the planned route showed the robot really did take a different corridor,
  one that happened to be the same length. The timing alone would have been misleading.

**Later the same day:** recorded the demo video (`docs/demo.mp4`, 67 s, all 3 goals reached
with the box in place) and published the repo. Cropped the desktop's status bar out of the
video before publishing, because it showed the Wi-Fi network name.

**Open:** the form answers are still to do. The submission link on the assignment page is
missing, so ask Antropi for it.
