// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {AggregatorV3Interface} from "chainlink-evm/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IEulerSwapPeriphery} from "./interfaces/IEulerSwapPeriphery.sol";

contract Pillow is ERC4626, Ownable(msg.sender) {
  AggregatorV3Interface public immutable priceFeed;
  IEulerSwapPeriphery public eulerPeriphery;

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
  function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
    // prettier-ignore
    (
      /* uint80 roundId */,
      int256 answer,
      /*uint256 startedAt*/,
      /*uint256 updatedAt*/,
      /*uint80 answeredInRound*/
    ) = priceFeed.latestRoundData();
    return answer;
  }
}
