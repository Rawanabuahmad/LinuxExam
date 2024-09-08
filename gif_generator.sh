#!/bin/bash

# Log file
LOG_FILE="gif_generator.log"

# Log function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" >> "$LOG_FILE"
}

# Check if enough parameters were supplied
if [ "$#" -lt 4 ]; then
    log "Error: Not enough parameters supplied."
    echo "Usage: $0 <image> <resolution_percentage> <rotation_angle> <num_images> [output_gif]"
    exit 1
fi

# Assign parameters
IMAGE=$1
RESOLUTION=$2
ROTATION=$3
NUM_IMAGES=$4
OUTPUT_GIF=${5:-}

# Check if output filename is provided, otherwise create a name
if [ -z "$OUTPUT_GIF" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    OUTPUT_GIF="${IMAGE%.*}_animation_$TIMESTAMP.gif"
    log "No output file provided. Using generated name: $OUTPUT_GIF"
fi

# Check if the input image exists
if [ ! -f "$IMAGE" ]; then
    log "Error: Input image '$IMAGE' does not exist."
    echo "Error: Input image '$IMAGE' does not exist."
    exit 1
fi
log "Input image exists: $IMAGE"

# Check if ImageMagick (convert command) is installed
if ! command -v convert &> /dev/null; then
    log "ImageMagick not found. Installing on Ubuntu."

    # Install ImageMagick directly using apt-get
    sudo apt-get update
    sudo apt-get install -y imagemagick

    # Verify installation
    if ! command -v convert &> /dev/null; then
        log "Error: Failed to install ImageMagick."
        echo "Error: Failed to install ImageMagick."
        exit 1
    fi
    log "ImageMagick installation successful."
fi

# Create a directory to store temporary images
TEMP_DIR="temp_images"
mkdir -p "$TEMP_DIR"
log "Created temporary directory: $TEMP_DIR"

# Step 1: Reduce resolution
log "Reducing image resolution by $RESOLUTION%."
convert "$IMAGE" -resize "$RESOLUTION%" "$TEMP_DIR/resized_image.jpg"

# Step 2: Generate rotated images
log "Generating $NUM_IMAGES rotated images."
for ((i = 0; i < NUM_IMAGES; i++)); do
    DEGREE=$((i * ROTATION))
    convert "$TEMP_DIR/resized_image.jpg" -rotate "$DEGREE" "$TEMP_DIR/image_$i.jpg"
    log "Generated image_$i.jpg with $DEGREE degrees rotation."
done

# Step 3: Create animation
log "Creating GIF animation: $OUTPUT_GIF"
convert -delay 20 -loop 0 "$TEMP_DIR/image_*.jpg" "$OUTPUT_GIF"

# Step 4: Cleanup
log "Cleaning up temporary images."
rm -rf "$TEMP_DIR"

# Done
log "GIF animation created successfully: $OUTPUT_GIF"
echo "GIF animation created successfully: $OUTPUT_GIF"
