// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Pillow} from "../src/Pillow.sol";

// base 1inch router: 

contract DeployerScript is Script {
  Pillow public pillow;

  function setUp() public {}

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    pillow = new Pillow(
      "Pillow",
      "PILLOW",
      0x0000000000000000000000000000000000000000,
      0x694AA1769357215DE4FAC081bf1f309aDC325306,
      0x18e5F5C1ff5e905b32CE860576031AE90E1d1336
    );

    vm.stopBroadcast();
  }
}
