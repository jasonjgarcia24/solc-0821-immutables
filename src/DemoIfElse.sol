// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {_NUMBER_, DemoBase} from "./DemoBase.sol";

contract DemoIfElse is DemoBase {
    constructor(bool _setCondition) {
        if (_setCondition) {
            number = _NUMBER_;
        }
    }
}
