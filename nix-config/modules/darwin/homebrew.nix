# GUI apps for macOS.
#
# Nix packages GUI Mac apps badly, so use Homebrew casks for them and
# keep the list declarative here.
#
# Homebrew itself must exist before the first build. Install it once:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "zap" removes anything not listed below. This is what makes the
      # list declarative. Use "uninstall" if that feels too strict.
      cleanup = "zap";
    };

    # CLI tools that are broken or missing in nixpkgs on darwin.
    brews = [
      "mas" # Mac App Store CLI, needed for masApps below
    ];

    casks = [
      # terminal and editors
      "ghostty"
      "visual-studio-code"

      # development
      "docker-desktop"
      "orbstack"

      # browsers
      "firefox"
      "google-chrome"

      # utilities
      "raycast"
      "rectangle"
      "keka"
    ];

    # You must be signed in to the App Store for these.
    # Find an ID with: mas search xcode
    masApps = {
      Xcode = 497799835;
    };
  };
}
