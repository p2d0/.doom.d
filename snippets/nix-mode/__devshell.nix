{ pkgs }:

with pkgs;

# Configure your development environment.
devshell.mkShell {
  name = "$1";
  motd = ''
Entered $2 app development environment.
'';
  env = [

  ];
  packages = [

  ];
}
