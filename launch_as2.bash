#!/bin/bash

usage() {
    echo "  options:"
  echo "      -r: record rosbag (ground_station)"
  echo "      -t: launch keyboard teleoperation (ground_station)"
}

## DEFAULTS
record_rosbag="false"
launch_keyboard_teleop="false"

# Arg parser
while getopts "rt" opt; do
  case ${opt} in
    r )
      record_rosbag="true"
      ;;
    t )
      launch_keyboard_teleop="true"
      ;;
    \? )
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    : )
      if [[ ! $OPTARG =~ ^[wrt]$ ]]; then
        echo "Option -$OPTARG requires an argument" >&2
        usage
        exit 1
      fi
      ;;
  esac
done

# HOW TO INCLUDE WORLDS OR MODELS FROM THE PROJECT
export IGN_GAZEBO_RESOURCE_PATH=$PWD/config/gazebo/models/worlds:$IGN_GAZEBO_RESOURCE_PATH
export GZ_SIM_RESOURCE_PATH=$PWD/config/gazebo/models/worlds:$GZ_SIM_RESOURCE_PATH
export GZ_SIM_RESOURCE_PATH=$PWD/config/gazebo/models/models:$GZ_SIM_RESOURCE_PATH

# if [[ ${record_rosbag} == "true" || ${launch_keyboard_teleop} == "true" ]]; then
#   tmuxinator start -n ground_station -p tmuxinator/ground_station.yaml \
#     launch_keyboard_teleop=${launch_keyboard_teleop} \
#     record_rosbag=${record_rosbag}
#   wait
# fi

tmuxinator start -n drone -p tmuxinator/aerostack2.yml \
    drone_namespace=${drone}
wait


# ros2 launch as2_gazebo_assets launch_simulation.py use_sim_time:=true simulation_config_file:=config/gazebo/world.yaml