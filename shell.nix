{
  lib ? import <lib> {},
  pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs/tarball/nixos-24.05){
    config.allowUnfree = true;
  }
}:

let


  # define packages to install with special handling for OSX
  basePackages = [
    pkgs.gnumake
    pkgs.gcc
    pkgs.readline
    pkgs.zlib
    pkgs.libxml2
    pkgs.libiconv
    pkgs.openssl
    pkgs.git
    pkgs.python3

    pkgs.postgresql

    pkgs.elixir_1_16
    pkgs.nodejs_18
    pkgs.yarn
    pkgs.license_finder

    pkgs.gh
    pkgs.ripgrep
    pkgs.jq
  ];

  inputs = basePackages
    ++ [ pkgs.bashInteractive ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.inotify-tools ]
    ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
        CoreFoundation
        CoreServices
      ]);

in pkgs.mkShell {
  buildInputs = inputs;
}
