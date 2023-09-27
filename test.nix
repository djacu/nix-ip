let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  nix-ip = import ./default.nix {inherit lib;};
  test = [
    {
      cidr = "192.168.70.9/15";
      truth = {
        bitMask = 15;
        ipAddress = "192.168.70.9";
        subnetMask = "255.254.0.0";
        networkId = "192.168.0.0";
        firstUsableIp = "192.168.0.1";
        lastUsableIp = "192.169.255.254";
        broadcast = "192.169.255.255";
      };
    }
    {
      cidr = "192.168.70.9/17";
      truth = {
        bitMask = 17;
        ipAddress = "192.168.70.9";
        subnetMask = "255.255.128.0";
        networkId = "192.168.0.0";
        firstUsableIp = "192.168.0.1";
        lastUsableIp = "192.168.127.254";
        broadcast = "192.168.127.255";
      };
    }
  ];
in
  builtins.all
  (
    elem: let
      output = nix-ip.getNetworkProperties elem.cidr;
      comparison = output == elem.truth;
    in
      if comparison
      then comparison
      else let
        findAttrsetsDiffs = x: y: let
          names = builtins.attrNames x;
        in
          builtins.map (name: x.${name} != y.${name}) names;

        truthDiffs = findAttrsetsDiffs output elem.truth;

        badNames = lib.flatten (lib.zipListsWith (bool: name:
          if bool
          then name
          else [])
        truthDiffs (builtins.attrNames output));
      in
        throw "Test for CIDR ${elem.cidr} failed ${builtins.toJSON badNames}."
  )
  test
