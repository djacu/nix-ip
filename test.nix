let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  nix-ip = import ./default.nix {inherit lib;};
  testIp = {
    testGetNetworkPropertiesTest1 = {
      expr = nix-ip.getNetworkProperties "192.168.70.9/15";
      expected = {
        bitMask = 15;
        ipAddress = "192.168.70.9";
        subnetMask = "255.254.0.0";
        networkId = "192.168.0.0";
        firstUsableIp = "192.168.0.1";
        lastUsableIp = "192.169.255.254";
        broadcast = "192.169.255.255";
      };
    };
    testGetNetworkPropertiesTest2 = {
      expr = nix-ip.getNetworkProperties "192.168.70.9/17";
      expected = {
        bitMask = 17;
        ipAddress = "192.168.70.9";
        subnetMask = "255.255.128.0";
        networkId = "192.168.0.0";
        firstUsableIp = "192.168.0.1";
        lastUsableIp = "192.168.127.254";
        broadcast = "192.168.127.255";
      };
    };
    testSubnetMaskToBitMask1 = {
      expr = nix-ip.subnetMaskToBitMask [0 0 0 0];
      expected = 0;
    };
    testSubnetMaskToBitMask2 = {
      expr = nix-ip.subnetMaskToBitMask [255 254 0 0];
      expected = 15;
    };
    testSubnetMaskToBitMask3 = {
      expr = nix-ip.subnetMaskToBitMask [255 255 1 0];
      expected = 17;
    };
    testSubnetMaskToBitMask4 = {
      expr = nix-ip.subnetMaskToBitMask [255 255 255 0];
      expected = 24;
    };
    testSubnetMaskToBitMask5 = {
      expr = nix-ip.subnetMaskToBitMask [255 255 255 255];
      expected = 32;
    };
  };

  message = msg: builtins.trace "[1;32mMessage: ${msg}[0m";

  testResults = lib.runTests testIp;
in
  if (builtins.length testResults == 0)
  then message "Everything passed! 😊" testResults
  else lib.warn "Something failed! ☹️" testResults
