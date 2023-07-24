// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {_NUMBER_, DemoBase} from "./DemoBase.sol";
import {IDemoEvents} from "./IDemo.sol";

library DemoLib {
    function forceFail(bool _pass) public pure {
        require(_pass, "force fail");
    }
}

contract DemoTryCatch is DemoBase, IDemoEvents {
    constructor(bool _setImmutable) {
        try DemoLib.forceFail(_setImmutable) {
            number = _NUMBER_;
        } catch {}
    }
}
