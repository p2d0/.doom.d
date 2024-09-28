{ pkgs }:

with pkgs;

# Configure your development environment.
devshell.mkShell {
  name = "__PROJECT-NAME__";
  motd = ''
Entered __PROJECT-NAME__ app development environment.
'';
  env = [
    {
      name = "PKG_CONFIG_PATH";
      value = "${openssl.dev}/lib/pkgconfig";
    }
  ];
  packages = [
    pkg-config
    openssl.dev
    libiconv
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    gdb
  ];
}
