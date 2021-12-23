{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "nixos-deploy" ''
  base_configuration=${./base_configuration}
  ${builtins.readFile ./nixos-deploy}
''
