// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {_NUMBER_} from "./DemoConstants.sol";

contract DemoIfElse {
    uint256 public immutable number;

    constructor(bool _setCondition) {
        if (_setCondition) {
            number = _NUMBER_;
        }
    }
}
