// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {_NUMBER_, _ALT_NUMBER_} from "./DemoConstants.sol";
import {IDemoEvents} from "./IDemo.sol";

contract DemoMultiAssignment is IDemoEvents {
    uint256 public immutable number;

    constructor() {
        number = _ALT_NUMBER_;
        emit Log("first setter", number);

        number = _NUMBER_;
        emit Log("second setter", number);
    }
}
