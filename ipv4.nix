{lib}: let
  bitMaskToSubnetMask = let
    # Generate a partial mask for an integer from 0 to 7
    #   part 1 = 128
    #   part 7 = 254
    part = n:
      if n == 0
      then 0
      else part (n - 1) / 2 + 128;
  in
    cidr: let
      # How many initial parts of the mask are full (=255)
      fullParts = cidr / 8;
    in
      lib.genList (
        i:
        # Fill up initial full parts
          if i < fullParts
          then 255
          # If we're above the first non-full part, fill with 0
          else if fullParts < i
          then 0
          # First non-full part generation
          else part (lib.mod cidr 8)
      )
      4;

  parseIpAddr = ipAddr:
    builtins.map lib.toInt (builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)" ipAddr);

  cidrToIpAddress = cidr: let
    splitParts = lib.splitString "/" cidr;
  in
    parseIpAddr (lib.elemAt splitParts 0);

  cidrToBitMask = cidr: let
    splitParts = lib.splitString "/" cidr;
  in
    lib.toInt (lib.elemAt splitParts 1);

  cidrToSubnetMask = cidr:
    bitMaskToSubnetMask (cidrToBitMask cidr);

  cidrToNetworkId = cidr: let
    ip = cidrToIpAddress cidr;
    subnetMask = cidrToSubnetMask cidr;
  in
    lib.zipListsWith lib.bitAnd ip subnetMask;

  cidrToLowerIp = cidr: let
    networkId = cidrToNetworkId cidr;
  in
    getLowerIp networkId;

  getLowerIp = ip: let
    lastOctet = lib.last ip;
    firstThree = lib.init ip;
  in
    firstThree ++ [(lastOctet + 1)];

  cidrToBroadcastAddress = cidr: let
    bitMask = cidrToBitMask cidr;
    networkId = cidrToNetworkId cidr;
  in
    getBroadcastAddress networkId (bitMaskToSubnetMask bitMask);

  getBroadcastAddress = networkId: bitMask:
    lib.zipListsWith (b: m: 255 - m + b) networkId bitMask;

  cidrToUpperIp = cidr: let
    broadcast = cidrToBroadcastAddress cidr;
    lastOctet = lib.last broadcast;
    firstThree = lib.init broadcast;
  in
    firstThree ++ [(lastOctet - 1)];

  getNetworkProperties = cidr: let
    ip = cidrToIpAddress cidr;
    bitMask = cidrToBitMask cidr;
    lower = cidrToLowerIp cidr;
    upper = cidrToUpperIp cidr;
    networkId = cidrToNetworkId cidr;
    subnetMask = cidrToSubnetMask cidr;
    broadcast = cidrToBroadcastAddress cidr;
  in {inherit ip bitMask lower upper networkId subnetMask broadcast;};
in {
  inherit
    cidrToIpAddress
    cidrToBitMask
    cidrToLowerIp
    cidrToUpperIp
    cidrToNetworkId
    cidrToSubnetMask
    cidrToBroadcastAddress
    getNetworkProperties
    ;
}
