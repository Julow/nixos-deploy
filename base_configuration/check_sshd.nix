{ config, options, lib, pkgs, ... }:

# Check that sshd is enabled.
# This module will be included when deploying to a remote machine to make sure
# it stays accessible over ssh.

{
  config = {
    assertions = [{
      assertion = config.services.openssh.enable;
      message = "sshd isn't enabled.";
    }];
  };
}
