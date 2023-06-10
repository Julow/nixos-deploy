{ configuration, system ? builtins.currentSystem, check_sshd ? true
, check_hostname ? true }:

let
  eval = extra_modules:
    import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;
      modules = (if check_hostname then [ ./check_hostname.nix ] else [ ])
        ++ (if check_sshd then [ ./check_sshd.nix ] else [ ]) ++ extra_modules;
    };

in {
  vm = (eval [
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ]).config.system.build.vm;

  system = let
    inherit (eval [ ]) config pkgs;
    inherit (config.system.build) toplevel;
  in pkgs.writeShellScriptBin "activate" ''
    current_hostname=`cat /etc/hostname`
    new_hostname='${config.networking.hostName}'
    if [[ $current_hostname != $new_hostname ]]; then
      echo "Warning: Deploying a system with hostname '$new_hostname' on a machine with hostname '$current_hostname'"
      if [[ $NO_CHECK_HOSTNAME -ne 1 ]]; then
        echo "Error: Set the environment variable 'NO_CHECK_HOSTNAME=1' to confirm."
        exit 1
      fi
    fi
    nix-env --profile /nix/var/nix/profiles/system --set '${toplevel}' &&
    /nix/var/nix/profiles/system/bin/switch-to-configuration switch
  '';
}
