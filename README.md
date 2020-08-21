# nixos-deploy

A small script to build and deploy a NixOS system.

## Installation

Obtain the package:

```nix
let nixos-deploy =
  let
    src = pkgs.fetchgit {
      url = "https://github.com/Julow/nixos-deploy";
      rev = "4e7ce58bbc80e00c5f4ac5e1fa4035b91ce9a752";
      sha256 = "0w5lz4q71b1axcdz6qglcg90f17zypk513n2fv235a7za7rq24ay";
    };
  in pkgs.callPackage src {};
in
```

And add it to your environment, in your NixOS configuration:

```nix
...
  environment.systemPackages = [
    ...
    nixos-deploy
  ];
...
```

## Usage: Local

```bash
  nixos-deploy deploy local my_desktop.nix
```

The system is built and activated. The activation will be run as root, using `su`, expect a password prompt.

If the current directory contain a directory named `nixpkgs`, it is used as nixpkgs.

## Usage: Remote

```bash
  nixos-deploy deploy ssh://root@my_server my_server.nix
```

The system is built locally and only the necessary files are sent to the remote server.
The system declaration cannot import nix files from the remote server, importing `/etc/nixos/hardware-configuration.nix` won't work. 
