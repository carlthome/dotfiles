#!/bin/sh
set -euo pipefail

youtube_url=$1

# Available models: tiny.en tiny base.en base small.en small medium.en medium large-v1 large
model='tiny'

# Download model weights (or use local cache if exists)
whisper-cpp-download-ggml-model $model

# Download YouTube video, resample audio to 16 kHz with ffmpeg, and run Whisper model on the audio stream.
yt-dlp -o - "${youtube_url}" |
	ffmpeg -hide_banner -loglevel error -i - -vn -acodec pcm_s16le -ar 16000 -ac 2 -f wav - |
	whisper-cpp --print-progress --print-colors --file - --language auto --model "ggml-${model}.bin" --output-txt
