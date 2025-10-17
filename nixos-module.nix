# nixos-module.nix
{ config, lib, pkgs, ... }:
let
  qemuPkg = config.services.vmrunner.qemuPackage or pkgs.qemu;
in
{
  options.services.vmrunner.qemuPackage = lib.mkOption {
    type = lib.types.package;
    default = pkgs.qemu;
    description = "QEMU with capabilities enabled for IncludeOS unikernels";
  };

  config.security.wrappers = {
    # https://wiki.qemu.org/Features/HelperNetworking
    qemu-bridge-helper = {
      source = "${qemuPkg}/libexec/qemu-bridge-helper";
      owner = "root";
      group = "root";
      capabilities = "cap_net_admin+ep";  # required for attaching TAP devices to bridges
    };

    ping = {
      source = "${pkgs.iputils}/bin/ping";
      owner = "root";
      group = "root";
      capabilities = "cap_net_raw+ep";  # required to send ICMP packets
    };
  };

  config.environment.etc."qemu/bridge.conf".text = ''
    allow bridge43
  '';
}

