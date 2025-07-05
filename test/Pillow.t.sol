// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {Pillow} from "../src/Pillow.sol";

address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

contract PillowTest is Test {
  Pillow public pillow;
  uint256 public baseMainetFork;

  address private owner = makeAddr("owner");
  address private user1 = makeAddr("user1");
  address private user2 = makeAddr("user2");
  address private user3 = makeAddr("user3");
  address private holderUSDC = 0xee81B5Afc73Cf528778E0ED98622e434E5eFADb4;

  function setUp() public {
    baseMainetFork = vm.createFork("https://base-mainnet.public.blastapi.io");
    vm.selectFork(baseMainetFork);

    vm.deal(holderUSDC, 1000000000000000000000000);
    vm.startPrank(holderUSDC);
    IERC20(USDC).transfer(address(user1), 100e6);
    vm.stopPrank();

    assertEq(IERC20(USDC).balanceOf(address(user1)), 100e6);
  }

  function testDeployPillow() public {
    assertEq(vm.activeFork(), baseMainetFork);

    vm.startPrank(owner);

    pillow = new Pillow(
      "Pillow",
      "PILLOW",
      0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, // USDC BASE
      0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70, // ETH/USDC BASE PRICE FEED
      0x18e5F5C1ff5e905b32CE860576031AE90E1d1336 // BASE EULER ROUTER
    );
    console2.log("[pillow] address", address(pillow));

    vm.stopPrank();

    assertEq(pillow.name(), "Pillow");
    assertEq(pillow.symbol(), "PILLOW");
    assertEq(pillow.asset(), 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    assertEq(address(pillow.eulerPeriphery()), 0x18e5F5C1ff5e905b32CE860576031AE90E1d1336);
  }

  function testGetChainlinkDataFeedLatestAnswer() public {
    testDeployPillow();
    (int256 latestAnswer, uint256 decimals) = pillow.getChainlinkDataFeedLatestAnswer();
    console2.log("latest answer", latestAnswer);
    console2.log("decimals", decimals);
    require(latestAnswer > 0, "latest answer is not greater than 0");
  }

  function depositUSDC(Pillow _pillow) public {
    vm.startPrank(user1);
    IERC20(USDC).approve(address(_pillow), 10e6);
    uint256 shares = _pillow.deposit(10e6, address(user1));
    console2.log("shares", shares);
    vm.stopPrank();
  }

  function testDeposit() public {
    testDeployPillow();
    depositUSDC(pillow);
  }

  function testRebalance() public {
    testDeployPillow();
    depositUSDC(pillow);
    vm.startPrank(user1);
    uint256 totalBalance = pillow.rebalance(1000, 9000);
    console2.log("totalBalance", totalBalance);
    vm.stopPrank();
  }

  function testTotalAssets() public {
    testDeployPillow();
    depositUSDC(pillow);
    uint256 totalBalance = pillow.totalAssets();
    console2.log("totalBalance", totalBalance);
  }
}
