{
  pkgs,
  whisper-cpp,
  ffmpeg,
  yt-dlp,
  ...
}:
pkgs.writeShellApplication {
  name = "youtube-transcribe";
  runtimeInputs = [
    whisper-cpp
    ffmpeg
    yt-dlp
  ];
  text = builtins.readFile ./script.sh;
}
