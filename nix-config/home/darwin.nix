# User configuration for macOS only.
{ pkgs, username, ... }:
{
  imports = [ ./core.nix ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.packages = with pkgs; [
    # Mac only CLI tools go here.
    cocoapods
  ];

  # Swift and iOS work uses Xcode, not Nix. After Xcode installs, run:
  #   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  #   sudo xcodebuild -license accept
}
