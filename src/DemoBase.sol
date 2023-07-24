// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

uint256 constant _NUMBER_ = 24;
uint256 constant _ALT_NUMBER_ = type(uint256).max;

abstract contract DemoBase {
    uint256 public immutable number;
}
