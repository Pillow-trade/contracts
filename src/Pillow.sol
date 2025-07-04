// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract Pillow is ERC4626 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _asset
    ) ERC4626(IERC20(_asset)) ERC20(_name, _symbol) {}
}
