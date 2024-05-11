#!/bin/bash

directory="${1:-"/home/u000000/2_Semester/EMLI-mini-project/src/Cloud"}"
model_version="${2:-"llava:7b"}"

ollama run $model_version &

perform_annotation() {
    IMAGENAME=$1
    SIDECARTYPE=".json"

    img64=$(base64 -w 0 $IMAGENAME)

    output=$(curl http://localhost:11434/api/generate -d '{ "model": "llava", "prompt":"Describe the picture in one sentence", "images": ["'$img64'"]}')

    if [ $? -eq 0 ]; then
        final_output=$(echo $output | jq -r '.response' | tr -d '\n')

        json_annotation="{\"Annotation\": {\"Source\": \"Ollama:$ollama_model_version\", \"Test\": \"$final_output\"}}"

        # Get the json file name from the image name
        json_file="${IMAGENAME%.*}$SIDECARTYPE"
        jq -s '.[0] * .[1]' <(echo "$json_annotation") "$json_file" > temp.json && mv temp.json "$json_file"

        echo "Ollama worked on $IMAGENAME"
    else
        echo "Ollama didn't work on $IMAGENAME"
    fi
}

# Export the function so it can be used in subshells
export -f perform_annotation
export MODEL_VERSION

find "$directory" -type f -name "*.jpg" -exec bash -c 'perform_annotation "$0"' {} \;