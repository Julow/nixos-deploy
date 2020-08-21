{ pkgs ? import <nixpkgs> {} }:

let
  copyScriptBin = f:
    pkgs.writeScriptBin (baseNameOf f) (builtins.readFile f);
in

copyScriptBin ./nixos-deploy
