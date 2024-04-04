# -*- mode: snippet -*-
#
{ pkgs }:

with pkgs;

# Configure your development environment.
devshell.mkShell {
  name = "$1";
  motd = ''
Entered $2 app development environment.
'';
  env = [
    # {
    #   name = "ANDROID_HOME";
    #   value = "${android-sdk}/share/android-sdk";
    # }
    # {
    #   name = "PATH";
    #   prefix = "${android-sdk}/bin";
    # }
  ];
  packages = [

  ];
}
