#!/bin/bash

img64=$(base64 -w 0 /home/u000000/2_Semester/EMLI-mini-project/src/RPi/Cloud/2024-05-06/150112_851.jpg)

output=$(curl http://localhost:11434/api/generate -d '{ "model": "llava", "prompt":"What is in this picture?", "images": ["'$img64'"]}')

echo $output


# perform_annotation() {
#     IMAGENAME="$1"
#     SIDECARTYPE=".json"

#     output=$(ollama run llava:${ollama_model_version} "describe $IMAGENAME")

#     if [ $? -eq 0 ]; then
#         echo "  \"Annotation\": {\"Source\": \"Ollama:$ollama_model_version\", \"Test\": \"$output\"}," >> $FOLDER$IMAGENAME$SIDECARTYPE
#         echo "Ollama worked on $IMAGENAME"
#     else
#         echo "Ollama didn't work on $IMAGENAME"
#     fi
# }

# # Export the function so it can be used in subshells
# export -f perform_annotation
# export MODEL_VERSION

# find "$directory" -type f -name "*.jpg" -exec bash -c 'perform_annotation "$0"' {} \;