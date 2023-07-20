#!/bin/sh
set -ex

videoid=$1

# Available models: tiny.en tiny base.en base small.en small medium.en medium large-v1 large.
model_version=${2:-'tiny'}
model="ggml-$model_version.bin"

# Download model weights (or use local download if exists)
whisper-cpp-download-ggml-model "$model_version"

# Download audio from YouTube video.
yt-dlp --format bestaudio --extract-audio --audio-format wav "$videoid"

# Get filename of downloaded audio.
filename=$(yt-dlp --get-filename "$videoid")

# Strip file extension.
filename="${filename%.*}"

# Resample audio to 16 kHz with ffmpeg (as expected by Whisper).
ffmpeg -loglevel warning -i "$filename.wav" -vn -acodec pcm_s16le -ar 16000 -ac 1 -f wav "$filename-16khz.wav"

# Transcribe speech with Whisper model.
whisper-cpp --file "$filename-16khz.wav" --output-file "$filename" --language auto --model "$model" --output-txt --output-srt
