#!/usr/bin/env python3
"""Set the robot's starting pose, then send Nav2 a sequence of goals in turtlebot3_world.

Nav2 plans every path itself; this script only says where to go.
"""
import sys
import time

import rclpy
from geometry_msgs.msg import PoseStamped
from nav2_simple_commander.robot_navigator import BasicNavigator, TaskResult

START = (-2.0, -0.5)  # matches the spawn pose in nav2_bringup's tb3_simulation_launch.py
# Goals on the far side of the pillar grid, so every leg has to route around obstacles.
GOALS = [(1.6, 0.5), (0.5, 1.6), (-1.6, -0.5)]


def pose(nav, x, y):
    p = PoseStamped()
    p.header.frame_id = 'map'
    p.header.stamp = nav.get_clock().now().to_msg()
    p.pose.position.x, p.pose.position.y = x, y
    p.pose.orientation.w = 1.0
    return p


def main():
    rclpy.init()
    nav = BasicNavigator()
    nav.setInitialPose(pose(nav, *START))
    nav.waitUntilNav2Active()

    failed = 0
    for x, y in GOALS:
        t0 = time.monotonic()
        nav.goToPose(pose(nav, x, y))
        while not nav.isTaskComplete():
            fb = nav.getFeedback()
            if fb:
                print(f'  -> ({x}, {y}) remaining {fb.distance_remaining:.2f} m', end='\r')
        result = nav.getResult()
        print(f'\ngoal ({x}, {y}): {result.name} in {time.monotonic() - t0:.1f} s')
        failed += result != TaskResult.SUCCEEDED

    rclpy.shutdown()
    sys.exit(failed)


if __name__ == '__main__':
    main()
