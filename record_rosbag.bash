#!/bin/bash

# Get file name from argument. Default use config.yaml
if [ "$#" -eq 1 ]; then
  CONFIG_FILE="$1"
else
  CONFIG_FILE="config/rosbag_topics.yaml"
fi

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration file path (absolute path)
CONFIG_FILE="$SCRIPT_DIR/$CONFIG_FILE"

# Check if the config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Configuration file not found in $CONFIG_FILE"
  exit 1
fi

# Parse excluded topics
declare -a EXCLUDE_TOPICS=()
in_exclude_section=false
while IFS= read -r line; do
  # Trim whitespace
  trimmed="${line#\"${line%%[![:space:]]*}\"}"
  trimmed="${trimmed%\"${trimmed##*[![:space:]]}\"}"
  if [[ "$trimmed" == "# Excluded topics:" ]]; then
    in_exclude_section=true
    continue
  fi
  if [[ "$trimmed" == "# End excluded topics" ]]; then
    in_exclude_section=false
    break
  fi
  if $in_exclude_section; then
    # Skip comments or empty lines
    [[ "$trimmed" =~ ^#.*$ || -z "$trimmed" ]] && continue
    EXCLUDE_TOPICS+=("$trimmed")
  fi
done < "$CONFIG_FILE"

# Create directory for rosbag storage
mkdir -p rosbags
cd rosbags || exit

# Generate a unique name with fixed prefix and two-digit number
prefix="flight_"
for i in $(seq -w 0 99); do
  filename="${prefix}${i}"
  if [[ ! -e "$filename" ]]; then
    ROSBAG_NAME="$filename"
    break
  fi
done

# If no available name was found
if [[ -z "$ROSBAG_NAME" ]]; then
  echo "Error: Could not find an available name for the rosbag (flight_00 to flight_99 are taken)"
  exit 1
fi

# Construct the rosbag record command
rosbag_cmd="ros2 bag record"

# Check if first non-empty line starts with '--'
FIRST_LINE=$(grep -v '^[[:space:]]*$' "$CONFIG_FILE" | grep -v '^[[:space:]]*#' | head -n1 | sed 's/^[[:space:]]*//')

if [[ "$FIRST_LINE" =~ ^-- ]]; then
  # Add the entire FIRST_LINE (all parameters) to the rosbag command
  rosbag_cmd+=" $FIRST_LINE"
else
  # Read topics from the config file, ignoring comments (#) and disabled topics (!)
  while IFS= read -r topic; do
    [[ "$topic" =~ ^#.*$ || "$topic" =~ ^!.*$ || -z "$topic" ]] && continue  # Skip comments, disabled topics, and empty lines
    rosbag_cmd+=" ${topic}"
  done < "$CONFIG_FILE"

  # Check if any topics were added
  if [[ "$rosbag_cmd" == "ros2 bag record" ]]; then
    echo "Warning: No valid topics found in $CONFIG_FILE"
    exit 1
  fi
fi

# Add exclude regex if any topics to exclude
if [ "${#EXCLUDE_TOPICS[@]}" -gt 0 ]; then
  # Anchor each topic to match exactly (start-to-end)
  patterns=""
  for t in "${EXCLUDE_TOPICS[@]}"; do
    patterns+="^${t}$|"
  done
  # Remove trailing '|' and wrap in parentheses
  regex="(${patterns%|})"
  rosbag_cmd+=" --exclude \"${regex}\""
fi

# Create main rosbag directory with subdirectories
mkdir -p "${ROSBAG_NAME}/config"
mkdir -p "${ROSBAG_NAME}/tmuxinator"

# Copy config and tmuxinator folders if they exist
if [[ -d "$SCRIPT_DIR/config" ]]; then
  cp -r "$SCRIPT_DIR/config"/* "${ROSBAG_NAME}/config/"
  echo "Config folder copied to ${ROSBAG_NAME}/config/"
fi

if [[ -d "$SCRIPT_DIR/tmuxinator" ]]; then
  cp -r "$SCRIPT_DIR/tmuxinator"/* "${ROSBAG_NAME}/tmuxinator/"
  echo "Tmuxinator folder copied to ${ROSBAG_NAME}/tmuxinator/"
fi

# Add output name to the command
rosbag_cmd+=" -o ${ROSBAG_NAME}/${ROSBAG_NAME}"

echo $rosbag_cmd
echo "Rosbag name: ${ROSBAG_NAME}"
echo "Starting rosbag recording..."

# Execute the rosbag record command
eval "$rosbag_cmd"