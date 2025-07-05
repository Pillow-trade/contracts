// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {AggregatorV3Interface} from "chainlink-evm/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IEulerSwapPeriphery} from "./interfaces/IEulerSwapPeriphery.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {console2} from "forge-std/Test.sol";

contract Pillow is ERC4626, Ownable(msg.sender) {
  using Math for uint256;
  AggregatorV3Interface public immutable priceFeed;
  IEulerSwapPeriphery public eulerPeriphery;
  address public eulerSwapper = 0x0D3d0F97eD816Ca3350D627AD8e57B6AD41774df;
  address public eulerVerifier = 0x30660764A7a05B84608812C8AFC0Cb4845439EEe;
  address public riskyAsset = 0x4200000000000000000000000000000000000006; // WETH
  uint256 public constant PERCENTAGE_PRECISION = 10000;
  uint256 public safeAssetDecimals = 6;
  uint256 public riskyAssetDecimals = 18;

  constructor(
    string memory _name,
    string memory _symbol,
    address _asset,
    address _priceFeed,
    address _eulerPeriphery
  ) ERC4626(IERC20(_asset)) ERC20(_name, _symbol) {
    priceFeed = AggregatorV3Interface(_priceFeed);
    eulerPeriphery = IEulerSwapPeriphery(_eulerPeriphery);
  }

  function setEulerPeriphery(address _eulerPeriphery) external onlyOwner {
    eulerPeriphery = IEulerSwapPeriphery(_eulerPeriphery);
  }

  // https://docs.chain.link/data-feeds/using-data-feeds
  function getChainlinkDataFeedLatestAnswer() public view returns (int256, uint256) {
    // prettier-ignore
    (
      /* uint80 roundId */,
      int256 answer,
      /*uint256 startedAt*/,
      /*uint256 updatedAt*/,
      /*uint80 answeredInRound*/
    ) = priceFeed.latestRoundData();
    uint256 decimals = priceFeed.decimals();
    return (answer, decimals);
  }

  //252283340000

  function rebalance(uint256 _percentageSafeAsset, uint256 _percentageRiskyAsset) external returns (uint256) {
    require(_percentageSafeAsset + _percentageRiskyAsset == PERCENTAGE_PRECISION, "Invalid percentage");
    uint256 totalBalance = totalAssets();
    uint256 totalRiskyInSafe = totalRiskyAssetsInSafe();
    uint256 totalSafe = totalSafeAssets();

    uint256 percentageRisky = totalRiskyInSafe / totalBalance * PERCENTAGE_PRECISION;
    uint256 percentageSafe = totalSafe / totalBalance * PERCENTAGE_PRECISION;

    console2.log("percentageRisky", percentageRisky);
    console2.log("percentageSafe", percentageSafe);

    return totalBalance;
  }

  function totalSafeAssets() public view returns (uint256) {
    uint256 balanceSafe = IERC20(asset()).balanceOf(address(this));
    uint256 difference = riskyAssetDecimals - safeAssetDecimals;
    uint256 balanceSafeInWei = balanceSafe * 10 ** difference;
    return balanceSafeInWei;
  }

  function totalRiskyAssetsInSafe() public view returns (uint256) {
    (int256 price, uint256 decimals) = getChainlinkDataFeedLatestAnswer();
    uint256 balanceRisky = IERC20(riskyAsset).balanceOf(address(this));
    uint256 difference = riskyAssetDecimals - decimals;
    uint256 balanceRiskyInSafe = balanceRisky * uint256(price) * 10 ** difference;
    return balanceRiskyInSafe;
  }

  function totalAssets() public view override returns (uint256) {
    uint256 balanceRiskyInSafe = totalRiskyAssetsInSafe();
    uint256 balanceSafeInWei = totalSafeAssets();

    return balanceRiskyInSafe + balanceSafeInWei;
  }
}

