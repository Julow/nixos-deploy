# nixos-deploy

A small script to build and deploy a NixOS system.

## Installation: in user environment

```sh
git clone "https://github.com/Julow/nixos-deploy"
cd nixos-deploy
nix-env -if .
```

To update, fetch the new version and run `nix-env -if .` again.
To uninstall, run `nix-env -e nixos-deploy`.

## Installation: in system packages

```nix
let nixos-deploy =
  let
    src = pkgs.fetchgit {
      url = "https://github.com/Julow/nixos-deploy";
      rev = "6e15213f01b2633d3c923c7f7626187e93d7d30b";
      sha256 = "1c3h2mmc07l4rmzfvjkhpiss6i7p1d0qplmn6j753h4yyh5py9kw";
    };
  in pkgs.callPackage src {};
in
```

And add it to your environment, in your NixOS configuration:

```nix
  environment.systemPackages = [
    # other packages here ...
    nixos-deploy
  ];
```

## Usage: Local

```bash
  nixos-deploy deploy local my_desktop.nix
```

The system is built and activated. The activation will be run as root, using `su`, expect a password prompt.

If the current directory contain a directory named `nixpkgs`, it is used as nixpkgs.

`my_desktop.nix` is expected to be a NixOS configuration, example use:

common.nix:

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    my packages
  ];

  users.users... # users

  # Other configuration you want to share between several machines
}
```

my_desktop.nix:

```nix
let
  hardware-configuration =
    # copy-paste your /etc/nixos/hardware-configuration.nix here:
    #   { config, lib, pkgs, ... }:
    #   ...
    ;
in

{
  imports = [
    hardware-configuration
    ./common.nix
  ];

  # Insert here your configurations specific to this machine, example:

  boot.loader...

  networking.interfaces...

  services.xserver = {
    videoDrivers = ...;
    dpi = ...;
  };

  system.stateVersion = ... # Keep the value you currently use
}
```

## Usage: Remote

```bash
  nixos-deploy deploy ssh://root@my_server my_server.nix
```

The system is built locally and only the necessary files are sent to the remote server.
The system declaration cannot import nix files from the remote server, importing `/etc/nixos/hardware-configuration.nix` won't work. 

## Usage: Updating the nixpkgs submodule

If a directory named `./nixpkgs` exists, it is used as nixpkgs.
If it is a Git submodule or a Git repository, this command will update it:

```sh
  nixos-deploy update nixos-20.09-small
```

Channel names are one of [nixpkgs-channels](https://github.com/NixOS/nixpkgs-channels),
this command show available channels:

```sh
  nixos-deploy update
```
