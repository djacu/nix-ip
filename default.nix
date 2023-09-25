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

  /*
  Given a CIDR, return the IP Address.

  Type: cidrToIpAddress :: str -> [ int ]

  Examples:
    cidrToIpAddress "192.168.70.9/15"
    => [ 192 168 70 9 ]
  */
  cidrToIpAddress = cidr: let
    splitParts = lib.splitString "/" cidr;
  in
    parseIpAddr (lib.elemAt splitParts 0);

  /*
  Given a CIDR, return the bitmask.

  Type: cidrToBitMask :: str -> int

  Examples:
    cidrToIpAddress "192.168.70.9/15"
    => 15
  */
  cidrToBitMask = cidr: let
    splitParts = lib.splitString "/" cidr;
  in
    lib.toInt (lib.elemAt splitParts 1);

  /*
  Given a CIDR, return the associated subnet mask.

  Type: cidrToSubnetMask :: str -> [ int ]

  Examples:
    cidrToSubnetMask "192.168.70.9/15"
    => [ 255 254 0 0 ]
  */
  cidrToSubnetMask = cidr:
    bitMaskToSubnetMask (cidrToBitMask cidr);

  /*
  Given a CIDR, return the associated network ID.

  Type: cidrToNetworkId :: str -> [ int ]

  Examples:
    cidrToNetworkId "192.168.70.9/15"
    => [ 192 168 0 0 ]
  */
  cidrToNetworkId = cidr: let
    ip = cidrToIpAddress cidr;
    subnetMask = cidrToSubnetMask cidr;
  in
    lib.zipListsWith lib.bitAnd ip subnetMask;

  /*
  Given a CIDR, return the associated first usable IP address.

  Type: cidrToFirstUsableIp :: str -> [ int ]

  Examples:
    cidrToFirstUsableIp "192.168.70.9/15"
    => [ 192 168 0 0 ]
  */
  cidrToFirstUsableIp = cidr: let
    networkId = cidrToNetworkId cidr;
    lastOctet = lib.last networkId;
    firstThree = lib.init networkId;
  in
    firstThree ++ [(lastOctet + 1)];

  /*
  Given a CIDR, return the associated broadcast address.

  Type: cidrToBroadcastAddress :: str -> [ int ]

  Examples:
    cidrToBroadcastAddress "192.168.70.9/15"
    => [ 192 169 255 255 ]
  */
  cidrToBroadcastAddress = cidr: let
    subnetMask = cidrToSubnetMask cidr;
    networkId = cidrToNetworkId cidr;
  in
    getBroadcastAddress networkId subnetMask;

  /*
  Given a network ID and subnet mask, return the associated broadcast address.

  Type: getBroadcastAddress :: [ int ] -> [ int ] -> [ int ]

  Examples:
    getBroadcastAddress [ 192 168 0 0 ] [ 255 254 0 0 ]
    => [ 192 169 255 255 ]
  */
  getBroadcastAddress = networkId: subnetMask:
    lib.zipListsWith (nid: mask: 255 - mask + nid) networkId subnetMask;

  /*
  Given a CIDR, return the associated last usable IP address.

  Type: cidrToLastUsableIp :: str -> [ int ]

  Examples:
    cidrToLastsableIp "192.168.70.9/15"
    => [ 192 169 255 254 ]
  */
  cidrToLastUsableIp = cidr: let
    broadcast = cidrToBroadcastAddress cidr;
    lastOctet = lib.last broadcast;
    firstThree = lib.init broadcast;
  in
    firstThree ++ [(lastOctet - 1)];

  /*
  Given a CIDR, return an attribute set of:
    the IP Address,
    the bit mask,
    the first usable IP address,
    the last usable IP address,
    the network ID,
    the subnet mask,
    the broadcast address.

  Type: getNetworkProperties :: str -> attrset

  Examples:
    getNetworkProperties "192.168.70.9/15"
    => {
      bitMask = 15;
      broadcast = [ 192 169 255 255 ];
      firstUsableIp = [ 192 168 0 1 ];
      ipAddress = [ 192 168 70 9 ];
      lastUsableIp = [ 192 169 255 254 ];
      networkId = [ 192 168 0 0 ];
      subnetMask = [ 255 254 0 0 ];
    }
  */
  getNetworkProperties = cidr: let
    ipAddress = cidrToIpAddress cidr;
    bitMask = cidrToBitMask cidr;
    firstUsableIp = cidrToFirstUsableIp cidr;
    lastUsableIp = cidrToLastUsableIp cidr;
    networkId = cidrToNetworkId cidr;
    subnetMask = cidrToSubnetMask cidr;
    broadcast = cidrToBroadcastAddress cidr;
  in {inherit ipAddress bitMask firstUsableIp lastUsableIp networkId subnetMask broadcast;};
in {
  inherit
    cidrToIpAddress
    cidrToBitMask
    cidrToFirstUsableIp
    cidrToLastUsableIp
    cidrToNetworkId
    cidrToSubnetMask
    cidrToBroadcastAddress
    getNetworkProperties
    ;
}
