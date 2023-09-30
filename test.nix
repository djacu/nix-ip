let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  ip = import ./ip.nix {inherit lib;};
  testIp = {
    testPrettyIp = {
      expr = ip.ipv4.prettyIp [192 168 70 9];
      expected = "192.168.70.9";
    };
    testBitMaskToSubnetMask1 = {
      expr = ip.ipv4.bitMaskToSubnetMask 15;
      expected = [255 254 0 0];
    };
    testBitMaskToSubnetMask2 = {
      expr = ip.ipv4.bitMaskToSubnetMask 24;
      expected = [255 255 255 0];
    };
    testSubnetMaskToBitMask1 = {
      expr = ip.ipv4.subnetMaskToBitMask [0 0 0 0];
      expected = 0;
    };
    testSubnetMaskToBitMask2 = {
      expr = ip.ipv4.subnetMaskToBitMask [255 254 0 0];
      expected = 15;
    };
    testSubnetMaskToBitMask3 = {
      expr = ip.ipv4.subnetMaskToBitMask [255 255 1 0];
      expected = 17;
    };
    testSubnetMaskToBitMask4 = {
      expr = ip.ipv4.subnetMaskToBitMask [255 255 255 0];
      expected = 24;
    };
    testSubnetMaskToBitMask5 = {
      expr = ip.ipv4.subnetMaskToBitMask [255 255 255 255];
      expected = 32;
    };
    testCidrToIpAddress1 = {
      expr = ip.ipv4.cidrToIpAddress "192.168.70.9/15";
      expected = [192 168 70 9];
    };
    testCidrToIpAddress2 = {
      expr = ip.ipv4.cidrToIpAddress "0.0.0.0/0";
      expected = [0 0 0 0];
    };
    testCidrToIpAddress3 = {
      expr = ip.ipv4.cidrToIpAddress "255.255.255.255/32";
      expected = [255 255 255 255];
    };
    testCidrToBitMask1 = {
      expr = ip.ipv4.cidrToBitMask "192.168.70.9/15";
      expected = 15;
    };
    testCidrToBitMask2 = {
      expr = ip.ipv4.cidrToBitMask "0.0.0.0/0";
      expected = 0;
    };
    testCidrToBitMask3 = {
      expr = ip.ipv4.cidrToBitMask "255.255.255.255/32";
      expected = 32;
    };
    testCidrToSubnetMask1 = {
      expr = ip.ipv4.cidrToSubnetMask "192.168.70.9/15";
      expected = [255 254 0 0];
    };
    testCidrToSubnetMask2 = {
      expr = ip.ipv4.cidrToSubnetMask "0.0.0.0/0";
      expected = [0 0 0 0];
    };
    testCidrToSubnetMask3 = {
      expr = ip.ipv4.cidrToSubnetMask "255.255.255.255/32";
      expected = [255 255 255 255];
    };
    testCidrToNetworkId1 = {
      expr = ip.ipv4.cidrToNetworkId "192.168.70.9/15";
      expected = [192 168 0 0];
    };
    testCidrToNetworkId2 = {
      expr = ip.ipv4.cidrToNetworkId "192.168.70.9/17";
      expected = [192 168 0 0];
    };
    testCidrToFirstUsableIp1 = {
      expr = ip.ipv4.cidrToFirstUsableIp "192.168.70.9/15";
      expected = [192 168 0 1];
    };
    testCidrToFirstUsableIp2 = {
      expr = ip.ipv4.cidrToFirstUsableIp "192.168.70.9/17";
      expected = [192 168 0 1];
    };
    testCidrToBroadcastAddress1 = {
      expr = ip.ipv4.cidrToBroadcastAddress "192.168.70.9/15";
      expected = [192 169 255 255];
    };
    testCidrToBroadcastAddress2 = {
      expr = ip.ipv4.cidrToBroadcastAddress "192.168.70.9/17";
      expected = [192 168 127 255];
    };
    testCidrToLastUsableIp1 = {
      expr = ip.ipv4.cidrToLastUsableIp "192.168.70.9/15";
      expected = [192 169 255 254];
    };
    testCidrToLastUsableIp2 = {
      expr = ip.ipv4.cidrToLastUsableIp "192.168.70.9/17";
      expected = [192 168 127 254];
    };
    testIncrementIp1 = {
      expr = ip.ipv4.incrementIp [192 168 70 9] 3;
      expected = [192 168 70 12];
    };
    testIncrementIp2 = {
      expr = ip.ipv4.incrementIp [192 168 70 9] (-2);
      expected = [192 168 70 7];
    };
    testIpAndBitMaskToCidr = {
      expr = ip.ipv4.ipAndBitMaskToCidr [192 168 70 9] 15;
      expected = "192.168.70.9/15";
    };
    testIpAndSubnetMaskToCidr = {
      expr = ip.ipv4.ipAndSubnetMaskToCidr [192 168 70 9] [255 254 0 0];
      expected = "192.168.70.9/15";
    };
    testGetNetworkPropertiesTest1 = {
      expr = ip.ipv4.getNetworkProperties "192.168.70.9/15";
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
      expr = ip.ipv4.getNetworkProperties "192.168.70.9/17";
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
  };

  message = msg: builtins.trace "[1;32mMessage: ${msg}[0m";

  testResults = lib.runTests testIp;
in
  if (builtins.length testResults == 0)
  then message "Everything passed! 😊" testResults
  else lib.warn "Something failed! ☹️" testResults
