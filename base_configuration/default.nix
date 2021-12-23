{ configuration, nixos ? import <nixpkgs/nixos> }:

nixos { configuration.imports = [ configuration ]; }
