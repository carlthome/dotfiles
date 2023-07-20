{ pkgs, openai-whisper-cpp, ffmpeg, yt-dlp, ... }: pkgs.writeShellApplication {
  name = "youtube-transcribe";
  runtimeInputs = [ openai-whisper-cpp ffmpeg yt-dlp ];
  text = builtins.readFile ./script.sh;
}
