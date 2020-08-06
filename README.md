# nixos-deploy

A small script to build and deploy a NixOS system to a remote server.

Usage:

```bash
  nixos-deploy deploy ssh://root@my_server my_server.nix
```

The system is built locally and only the necessary files are sent to the remote server.
The system declaration cannot import nix files from the remote server, importing `/etc/nixos/hardware-configuration.nix` won't work. 
