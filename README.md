# nixos-deploy

A small script to build and deploy a NixOS system.

With Nix version 2.4, this needs to be set in [nix.conf](https://nixos.org/manual/nix/unstable/command-ref/conf-file.html):
```
experimental-features = nix-command
```

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
      rev = "995ccabc200d27c0d811f950f3deb3083aee798f";
      sha256 = "0qslrnvia6y8zb5zrqjw89vj5zfzkh3wi18r2qpnnxa80qjqqmxd";
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

## Usage: nixpkgs submodule

If a directory named `./nixpkgs` exists, it is used as nixpkgs while building the system.
Global channels are ignored.

If it is a Git submodule or a Git repository, this command will update it:

```sh
nixos-deploy update nixos-21.11
```

Channel names are fetched from [nixpkgs-channels](https://github.com/NixOS/nixpkgs-channels),
this command show available channels:

```sh
nixos-deploy update
```

## Usage: Testing in a VM

This command will build the system, like the `deploy` command, and run it in a VM:

```sh
nixos-deploy vm my_desktop.nix
```

Also useful while testing, this command will build the system with "traces" enabled, to show more details in case of error:

```sh
nixos-deploy build my_desktop.nix
```

## Safety checks

The tool injects a NixOS module implementing these checks:

- `services.openssh.enable` is `true` when deploying to a remote machine.
  This check helps making sure that the remote machine will stay accessible
  after the system is switched.
  This check can't be disabled.

- The hostname of the new system is the same as the system currently installed.
  It first checks that the option `networking.hostName` is set then, before
  switching to the new system, it checks that `/etc/hostname` contains the same
  string.
  This check can be disabled by setting the environment variable
  `NO_CHECK_HOSTNAME=1`.
