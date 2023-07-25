// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {_NUMBER_, _ALT_NUMBER_} from "../src/DemoConstants.sol";
import {IDemoEvents} from "../src/IDemo.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";
import {DemoMultiAssignment} from "../src/DemoMultiAssignment.sol";
import {DemoIfElse} from "../src/DemoIfElse.sol";
import {DemoTryCatch} from "../src/DemoTryCatch.sol";

contract DemoTest is Test, IDemoEvents {
    function testDemoNoAssignment() public {
        DemoNoAssignment demo = new DemoNoAssignment();
        vm.label(address(demo), "DEMO");
        assertEq(demo.number(), 0);
    }

    function testDemoMultiAssignment() public {
        address _demoAddress = makeAddr("DEMO");

        vm.expectEmit(false, false, false, true, _demoAddress);
        emit Log("first setter", _ALT_NUMBER_);
        vm.expectEmit(false, false, false, true, _demoAddress);
        emit Log("second setter", _NUMBER_);
        deployCodeTo(
            "./out/DemoMultiAssignment.sol/DemoMultiAssignment.json",
            _demoAddress
        );

        assertEq(DemoMultiAssignment(_demoAddress).number(), _NUMBER_);
    }

    function testDemoIfElse() public {
        DemoIfElse demoFalse = new DemoIfElse(false);
        vm.label(address(demoFalse), "DEMO_FALSE");
        assertEq(demoFalse.number(), 0);

        DemoIfElse demoTrue = new DemoIfElse(true);
        vm.label(address(demoTrue), "DEMO_TRUE");
        assertEq(demoTrue.number(), _NUMBER_);
    }

    function testDemoTryCatch() public {
        DemoTryCatch demoFalse = new DemoTryCatch(false);
        vm.label(address(demoFalse), "DEMO_FALSE");
        assertEq(demoFalse.number(), 0);

        DemoTryCatch demoTrue = new DemoTryCatch(true);
        vm.label(address(demoTrue), "DEMO_TRUE");
        assertEq(demoTrue.number(), _NUMBER_);
    }
}
