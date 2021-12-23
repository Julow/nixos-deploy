{ config, options, lib, pkgs, ... }:

# Check that the hostname is set.
# The hostname of the previous system will be compared to the new one to be
# sure the right system is deployed to the right machine.

{
  config = {
    assertions = [{
      assertion = config.networking.hostName
        != options.networking.hostName.default;
      message = "'networking.hostName' isn't set.";
    }];
  };
}
