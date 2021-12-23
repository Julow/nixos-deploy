{ configuration, system ? builtins.currentSystem }:

let
  eval = extra_modules:
    import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;
      modules = [ configuration ./check_hostname.nix ] ++ extra_modules;
    };

in {
  vm = (eval [
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ]).config.system.build.vm;

  system = let
    inherit (eval [ ]) config pkgs;
    inherit (config.system.build) toplevel;
  in pkgs.writeShellScriptBin "activate" ''
    nix-env --profile /nix/var/nix/profiles/system --set '${toplevel}' &&
    /nix/var/nix/profiles/system/bin/switch-to-configuration switch
  '';
}
