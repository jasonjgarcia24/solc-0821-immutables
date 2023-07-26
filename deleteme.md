Solidity 0.8.21 Language Feature: Flexible Immutables
Image generated with Hotpot.aiIn the past, Solidity's handling of immutable variables has been quite rigid. However, the game has changed with the arrival of Solidity 0.8.21. Immutable variables, while still unchangeable after a contract's construction, now abide by a more flexible set of guidelines for their initialization and assignment. In short summary, explicit initialization is no longer a requirement.
In this article, we'll take a close look at ways to take advantage of this update from within our contracts. We'll cover how you can now read and write to Immutables at any time during contract construction, excluding from within functions and modifiers.
To help make things clearer, we'll use simple test examples with Foundry to demonstrate what this feature really means for developers through the use of our Demo* contracts.
This demo will be divided into four distinct examples:
Part 1: Immutables initialized only
Part 2: Immutables assigned multiple values
Part 3: Immutables assigned on condition
Part 4: Immutables assigned within a try/catch

Please remember: this article is for those who already have a basic understanding of Solidity, immutable variables, and Foundry testing. If you're new to these topics, I suggest taking a look at the official Solidity documentation and Foundry book's Test section.
Alright! Let's get started!
Project Config and Setup
Code: https://github.com/jasonjgarcia24/solc-0821-immutables
Solidity version: 0.8.20 and 0.8.21
Forge version: forge 0.2.0 (58a2729 2023–05–16T00:03:39.980639280Z)
IDE: VS Code

To begin, we'll create our Foundry environment by running the following command:
$ forge init
Your project's structure and the Foundry configuration should now be similar to the below (btw, please feel free to remove that last line):
Next, remove all the Counter*.sol contracts. You can also completely remove the script directory if you like. We will not be using it here.
We'll start with the creation of our DemoBase.sol and IDemo.sol abstract contract and interface.
$ touch ./src/DemoConstants.sol ./src/IDemo.sol
DemoConstants.sol:
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

uint256 constant _NUMBER_ = 24;
uint256 constant _ALT_NUMBER_ = type(uint256).max;
IDemo.sol:
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IDemoEvents {
    event Log(string message, uint256 number);
}
Notice our pragma solidity ^0.8.20 will allow us to use both solc versions 0.8.20 and 0.8.21.
In summary, these are two very basic items that will enable our contracts to share common constants and events.
Okay! We're ready to begin 🏁.
Part 1 - Immutables Initialized Only
For this test, we start off with a very simple contract.
$ touch ./src/DemoNoAssignment.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract DemoNoAssignment {
    uint256 public immutable number;
}
Now it doesn't get much simpler than this. Within our DemoNoAssignment contract, we simply declare our number immutable variable within our contract.
Since we are testing the solc update, our initial testing can be conducted through compilation of our DemoNoAssignment contract. Therefore, we'll use the forge build command to test the two solc version.
Starting with solc 0.8.20:
$ forge build --use 0.8.20 --contracts ./src/DemoNoAssignment.sol --skip test
[⠊] Compiling...
[⠒] Compiling 1 files with 0.8.20
[⠢] Solc 0.8.20 finished in 4.19ms
Error: 
Compiler run failed:
Error (2658): Construction control flow ends without initializing all immutable state variables.
 --> src/DemoNoAssignment.sol:4:1:
  |
4 | contract DemoNoAssignment {
  | ^ (Relevant source part starts here and spans across multiple lines).
Note: Not initialized: 
 --> src/DemoNoAssignment.sol:5:5:
  |
5 |     uint256 public immutable number;
  |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For this first use case of forge build, we'll break down our command.
forge build: builds our project's smart contracts
--use 0.8.20: use solc 0.8.20 for our contracts
--contracts ./src/DemoNoAssignment.sol: only build DemoNoAssignment.sol contract, skip all others
--skip test: do not build our contracts within the test folder as specified within our foundry.toml

Continuing on to our build results we can see that we encountered a compiler failure due to Construction control flow ends without initializing all immutable state variables. For 0.8.20, this is expected.
Now let's try with solc 0.8.21:
$ forge build --use 0.8.21 --contracts ./src/DemoNoAssignment.sol --skip test
[⠊] Compiling...
[⠒] Compiling 1 files with 0.8.21
[⠢] Solc 0.8.21 finished in 7.34ms
Compiler run successful!
Look at that new behavior! With 0.8.21, we now pass without initializing our immutable variable.
But this introduces a new question. If number is not initialized, then what is it?
To determine the value of number we can run a quick test sequence.
$ touch ./test/Demo.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";

contract DemoTest is Test {
    function testDemoNoAssignment() public {
        DemoNoAssignment demo = new DemoNoAssignment();
        vm.label(address(demo), "DEMO");
        assertEq(demo.number(), 0);
    }

}
For this test we can see that we're using the same pragma solidity ^0.8.20 which will allow us to use version0.8.21. We also have our imports for the Foundry test contract and our DemoNoAssignment contract.
pragma solidity ^0.8.20;

import {Test} "forge-std/Test.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";
Within our contract we create a new instance of the DemoNoAssignment contract to test. Next, to help with our test trace readability, we label the address of the demo contract instance with "DEMO". And finally, we conduct a sanity check on the expected value of the number immutable variable, which we expect to be 0.
DemoNoAssignment demo = new DemoNoAssignment();
vm.label(address(demo), "DEMO");
assertEq(demo.number(), 0);
Alright! Let's run our test!
$ forge test --use 0.8.21 --match-test testDemoNoAssignment -vvvv
[⠰] Compiling...
No files changed, compilation skipped

Running 1 test for test/Demo.t.sol:DemoTest
[PASS] testDemoNoAssignment() (gas: 66988)
Traces:
  [66988] DemoTest::testDemoNoAssignment() 
    ├─ [31099] → new DEMO@0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06
    │   └─ ← 155 bytes of code
    ├─ [0] VM::label(DEMO: [0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06], DEMO) 
    │   └─ ← ()
    ├─ [161] DEMO::number() [staticcall]
    │   └─ ← 0
    └─ ← ()

Test result: ok. 1 passed; 0 failed; finished in 356.85µs
As expected, we have a test result of [PASS] testDemoNoAssignment() ✅. But let's break down what actually happened.
First off we see the creation and labeling of our contract.
├─ [31099] → new DEMO@0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06
│   └─ ← 155 bytes of code
├─ [0] VM::label(DEMO: [0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06], DEMO) 
│   └─ ← ()
And at the end we see our call from within our testDemoAssignment() function to our number() function. This shows us the value of our number variable is indeed 0.
├─ [161] DEMO::number() [staticcall]
│   └─ ← 0
And that's it for Part 1 🍰. Now onto a bit more complex example!
Part 2 - Immutables Assigned Multiple Values
Starting off we'll create a DemoMultiAssignment contract.
$ touch ./src/DemoMultiAssignment.sol
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
As we can see in our contract, we have two instances within our contract's constructor where we are assigning our immutable variable a value. Hmm… not so immutable now are we 🤔.
Let's run through this contract with our forge build command to take a look the two different solc versions' differences.
$ forge build --use 0.8.20 --contracts ./src/DemoMultiAssignment.sol --skip test
[⠊] Compiling...
[⠒] Compiling 3 files with 0.8.20
[⠢] Solc 0.8.20 finished in 10.28ms
Error: 
Compiler run failed:
Error (1574): Immutable state variable already initialized.
  --> src/DemoMultiAssignment.sol:14:9:
   |
14 |         number = _NUMBER_;
   |         ^^^^^^
I won't go into the actual test command since it should be a near exact match to what we used before. The only change is to the contract we're actually building.
As we can see here in the failed compilation's results, we failed for Immutable state variable already initialized. What this tells us is that the very first number = _ALT_NUMBER_; assignment passed, however solc 0.8.20 does not allow th following number = _NUMBER_; assignment 🔍. This failure is expected.
Now building our contract with solc 0.8.21:
$ forge build --use 0.8.21 --contracts ./src/DemoMultiAssignment.sol --skip test
[⠊] Compiling...
[⠒] Compiling 3 files with 0.8.21
[⠢] Solc 0.8.21 finished in 12.74ms
Compiler run successful!
Fancy 😼. We can see here that 0.8.21 is perfectly fine with this assignment of our immutable variable more than once within our constructor.
Once again, let's run our Foundry test to see what's happening under the hood.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {_NUMBER_, _ALT_NUMBER_} from "../src/DemoConstants.sol";
import {IDemoEvents} from "../src/IDemo.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";
import {DemoMultiAssignment} from "../src/DemoMultiAssignment.sol";

contract DemoTest is Test, IDemoEvents {
    ...

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

    ...
}
For this test we've introduced a few more imports into our test contract. Now we are bringing in our constant variables, IDemoEvents interface, and our DemoMultiAssignment contract. We also see that we are inheriting our IDemoEvents interface directly into our test contract for easy access to the Log event.
import {Test} from "forge-std/Test.sol";
import {_NUMBER_, _ALT_NUMBER_} from "../src/DemoConstants.sol";
import {IDemoEvents} from "../src/IDemo.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";
import {DemoMultiAssignment} from "../src/DemoMultiAssignment.sol";

contract DemoTest is Test, IDemoEvents {
Within our testDemoMultiAssignment() test function, we'll once again start from top to bottom to understand what's happing.
address _demoAddress = makeAddr("DEMO");
Starting off we use Foundry's makeAddr() cheatcode to generate a determinstic address for our eventual Demo contract instance. Knowing this address before contract deployment will enable us to use Foundry's event emission check to make sure our Demo contract itself emitts the expected events.
vm.expectEmit(false, false, false, true, _demoAddress);
emit Log("first setter", _ALT_NUMBER_);
vm.expectEmit(false, false, false, true, _demoAddress);
emit Log("second setter", _NUMBER_);
Using Foundry's expectEmit() cheatcode, we are able to verify both events for logging the assignments of the number variable. If you'd like to read more on how to use the expectEmit() cheatcode, please check out my previous article Testing Events with Foundry.
deployCodeTo(
    "./out/DemoMultiAssignment.sol/DemoMultiAssignment.json",
    _demoAddress
);
Next, we use Foundry's deployCodeTo() cheatcode to "pseudo-deploy" our Demo contract to our predetermined _demoAddress. This cheatcode uses the supplied address as well as the contract bytecode from within the artifacts directory provided.
assertEq(DemoMultiAssignment(_demoAddress).number(), _NUMBER_);
Finally we have our sanity check to ensure the final assignment of our immutable variable is the actual value following contract construction.
Now to test this out 👩‍🏫.
$ forge test --use 0.8.21 --match-test testDemoMultiAssignment -vvvv
[⠊] Compiling...
[⠘] Compiling 25 files with 0.8.21
[⠒] Solc 0.8.21 finished in 2.67s
Compiler run successful!

Running 1 test for test/Demo.t.sol:DemoTest
[PASS] testDemoMultiAssignment() (gas: 19971)
Traces:
  [19971] DemoTest::testDemoMultiAssignment() 
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F]
    ├─ [0] VM::label(DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F], DEMO) 
    │   └─ ← ()
    ├─ [0] VM::expectEmit(false, false, false, true, DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F]) 
    │   └─ ← ()
    ├─ emit Log(message: first setter, number: 115792089237316195423570985008687907853269984665640564039457584007913129639935 [1.157e77])
    ├─ [0] VM::expectEmit(false, false, false, true, DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F]) 
    │   └─ ← ()
    ├─ emit Log(message: second setter, number: 24)
    .
    .
    .
    ├─ [4004] DEMO::fallback() 
    │   ├─ emit Log(message: first setter, number: 115792089237316195423570985008687907853269984665640564039457584007913129639935 [1.157e77])
    │   ├─ emit Log(message: second setter, number: 24)
    .
    .
    .
    ├─ [161] DEMO::number() [staticcall]
    │   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000018
    └─ ← ()

Test result: ok. 1 passed; 0 failed; finished in 7.73ms
As expected, our test runs to completion with a status of [PASS]. Please also note that I did remove a few lines of the test trace. This was done to help us stay focused on the important trace lines. With that prefaced, let's continue down through the trace.
├─ [0] VM::addr(<pk>) [staticcall]
│   └─ ← DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F]
├─ [0] VM::label(DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F], DEMO) 
│   └─ ← ()
First off we see the effects of Foundry's makeAddr() cheatcode. Not only does it create our address, but it also labels it with DEMO.
├─ [0] VM::expectEmit(false, false, false, true, DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F]) 
│   └─ ← ()
├─ emit Log(message: first setter, number: 115792089237316195423570985008687907853269984665640564039457584007913129639935 [1.157e77])
├─ [0] VM::expectEmit(false, false, false, true, DEMO: [0x4d3A66A687CA11e5e043B6900635A60B0BcA3A8F]) 
│   └─ ← ()
├─ emit Log(message: second setter, number: 24)
Next we see our test setup for our expected events. Notice the expected values are type(uint256).max and 24, or _ALT_NUMBER_ and _NUMBER_ respectively.
├─ [4004] DEMO::fallback() 
│   ├─ emit Log(message: first setter, number: 115792089237316195423570985008687907853269984665640564039457584007913129639935 [1.157e77])
│   ├─ emit Log(message: second setter, number: 24)
Then we have our call into our "pseudo-deployed` DemoMultiAssignment contract. We see here that we have two sequentially emitted Log events with number values of type(uint256).max and 24. That looks good 🤜🏽🤛🏻!
├─ [161] DEMO::number() [staticcall]
│   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000018
Finally we see that our number call from within our assertEq() sanity check is 0x18 which in decimal checks out to the expected final value of 24.
This is another perfect example of the increased flexibility that solc 0.8.21 brings to Solidity devs. With that being said, although we can reassign our number variable within our constructor during initial contract construction, once our constructor is complete, our immutables are locked forever to their values. Therefore, I still feel okay about calling immutables "immutables" 👌🏿.
Now onto our next section with conditionals!
Part 3 - Immutables Assigned on Condition
Given we've already covered so much, for Part 3 and Part 4 we will flow through the examples at a higher level pace. For cheatcode descriptions, please reference the previous explanations as well as the Foundry book for help.
We'll begin with a simple, new contract that sets the immutable variable on a specific condition using an if statement.
$ touch ./src/DemoIfElse.sol
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
Taking a quick look here, we can see that our contract's constructor takes in a _setCondition flag to determine whether or not our number immutable variable will be set by to our _NUMBER_ constant's value.
Conduct our expected build failure with solc 0.8.20:
$ forge build --use 0.8.20 --contracts ./src/DemoIfElse.sol --skip test
[⠊] Compiling...
[⠒] Compiling 2 files with 0.8.20
[⠢] Solc 0.8.20 finished in 2.75ms
Error: 
Compiler run failed:
Error (4599): Cannot write to immutable here: Immutable variables cannot be initialized inside an if statement.
  --> src/DemoIfElse.sol:11:13:
   |
11 |             number = _NUMBER_;
   |             ^^^^^^
We see here that we fail for Immutable variables cannot be initialized inside an if statement.
Now our expected successful build with solc 0.8.21:
$ forge build --use 0.8.21 --contracts ./src/DemoIfElse.sol --skip test
[⠊] Compiling...
[⠒] Compiling 2 files with 0.8.21
[⠢] Solc 0.8.21 finished in 13.71ms
Compiler run successful!
🤠
Now we build out our test:
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {_NUMBER_, _ALT_NUMBER_} from "../src/DemoConstants.sol";
import {IDemoEvents} from "../src/IDemo.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";
import {DemoMultiAssignment} from "../src/DemoMultiAssignment.sol";
import {DemoIfElse} from "../src/DemoIfElse.sol";

contract DemoTest is Test, IDemoEvents {
    ...

    function testDemoIfElse() public {
        DemoIfElse demoFalse = new DemoIfElse(false);
        vm.label(address(demoFalse), "DEMO_FALSE");
        assertEq(demoFalse.number(), 0);

        DemoIfElse demoTrue = new DemoIfElse(true);
        vm.label(address(demoTrue), "DEMO_TRUE");
        assertEq(demoTrue.number(), _NUMBER_);
    }

    ...
}
To generally explain what's happening here, we add our DemoIfElse contract to our imports, and within our new testDemoIfElse() test function we run two near duplicate tests on our DemoIfElse contract.
For the first test sequence, we input false for the _setCondition input argument. This will construct a DemoIfElse contract instance with its number immutable variable set permenately to the default value of 0.
DemoIfElse demoFalse = new DemoIfElse(false);
vm.label(address(demoFalse), "DEMO_FALSE");
assertEq(demoFalse.number(), 0);
For the second test sequence, we input true for the _setCondition input argument. This will construct a DemoIfElse contract instance with its number immutable variable set permenately to the default value of 24, or _NUMBER_.
DemoIfElse demoTrue = new DemoIfElse(true);
vm.label(address(demoTrue), "DEMO_TRUE");
assertEq(demoTrue.number(), _NUMBER_);
Now we run our test:
$ forge test --use 0.8.21 --match-test testDemoIfElse -vvvv
[⠊] Compiling...
[⠒] Compiling 25 files with 0.8.21
[⠊] Solc 0.8.21 finished in 3.47s
Compiler run successful!

Running 1 test for test/Demo.t.sol:DemoTest
[PASS] testDemoIfElse() (gas: 131737)
Traces:
  [131737] DemoTest::testDemoIfElse() 
    ├─ [31292] → new DEMO_FALSE@0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06
    │   └─ ← 155 bytes of code
    ├─ [0] VM::label(DEMO_FALSE: [0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06], DEMO_FALSE) 
    │   └─ ← ()
    ├─ [161] DEMO_FALSE::number() [staticcall]
    │   └─ ← 0
    ├─ [31301] → new DEMO_TRUE@0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63
    │   └─ ← 155 bytes of code
    ├─ [0] VM::label(DEMO_TRUE: [0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63], DEMO_TRUE) 
    │   └─ ← ()
    ├─ [161] DEMO_TRUE::number() [staticcall]
    │   └─ ← 24
    └─ ← ()

Test result: ok. 1 passed; 0 failed; finished in 403.88µs
Here we can see our test status is [PASS].
We can also see that our first test sequence is as expected with a confirmed value for number of 0.
├─ [31292] → new DEMO_FALSE@0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06
│   └─ ← 155 bytes of code
├─ [0] VM::label(DEMO_FALSE: [0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06], DEMO_FALSE) 
│   └─ ← ()
├─ [161] DEMO_FALSE::number() [staticcall]
│   └─ ← 0
And our second test sequence is also as expected with a confirmed value for number of 24.
├─ [31301] → new DEMO_TRUE@0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63
│   └─ ← 155 bytes of code
├─ [0] VM::label(DEMO_TRUE: [0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63], DEMO_TRUE) 
│   └─ ← ()
├─ [161] DEMO_TRUE::number() [staticcall]
│   └─ ← 24
Nice 🤓!
Now onto our fourth and final example!
Part 4 - Immutables Assigned Within a Try/Catch
For this example, we will be using Solidity's try/catch statement to set the immutable variable only when a non-revert condition occurs. Otherwise, we will again use the default immutable value.
Let's create our contract then.
$ touch ./src/DemoTryCatch.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {_NUMBER_} from "./DemoConstants.sol";

library DemoLib {
    function forceFail(bool _pass) public pure {
        require(_pass, "force fail");
    }
}

contract DemoTryCatch {
    uint256 public immutable number;

    constructor(bool _setImmutable) {
        try DemoLib.forceFail(_setImmutable) {
            number = _NUMBER_;
        } catch {}
    }
}
Here we notice that in addition to our DemoTryCatch contract, we've also created a DemoLib library. This library will allow our try/catch statement to exercise a fault case controlled by the _pass argument linked to the _setImmutable argument of the DemoTryCatch contract's constructor.
Okay, let's try this out with 0.8.20.
$ forge build --use 0.8.20 --contracts ./src/DemoTryCatch.sol --skip test
[⠊] Compiling...
[⠒] Compiling 2 files with 0.8.20
[⠢] Solc 0.8.20 finished in 2.23ms
Error: 
Compiler run failed:
Error (4130): Cannot write to immutable here: Immutable variables cannot be initialized inside a try/catch statement.
  --> src/DemoTryCatch.sol:17:13:
   |
17 |             number = _NUMBER_;
   |             ^^^^^^
As expected, we fail for Immutable variables cannot be initialized inside a try/catch statement.
Now with 0.8.21.
$ forge build --use 0.8.21 --contracts ./src/DemoTryCatch.sol --skip test
[⠊] Compiling...
[⠒] Compiling 2 files with 0.8.21
[⠢] Solc 0.8.21 finished in 30.78ms
Compiler run successful!
Also as expected. We have successful compilation!
Now for our test case.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {_NUMBER_, _ALT_NUMBER_} from "../src/DemoConstants.sol";
import {IDemoEvents} from "../src/IDemo.sol";
import {DemoNoAssignment} from "../src/DemoNoAssignment.sol";
import {DemoMultiAssignment} from "../src/DemoMultiAssignment.sol";
import {DemoIfElse} from "../src/DemoIfElse.sol";
import {DemoTryCatch} from "../src/DemoTryCatch.sol";

contract DemoTest is Test, IDemoEvents {
    ...

    function testDemoTryCatch() public {
        DemoTryCatch demoFalse = new DemoTryCatch(false);
        vm.label(address(demoFalse), "DEMO_FALSE");
        assertEq(demoFalse.number(), 0);

        DemoTryCatch demoTrue = new DemoTryCatch(true);
        vm.label(address(demoTrue), "DEMO_TRUE");
        assertEq(demoTrue.number(), _NUMBER_);
    }
}
This should look familiar to our DemoIfElse test case. Given the similarities, we'll continue straight into running our test.
$ forge test --use 0.8.21 --match-test testDemoTryCatch -vvvv
[⠊] Compiling...
[⠑] Compiling 25 files with 0.8.21
[⠒] Solc 0.8.21 finished in 3.62s
Compiler run successful!

Running 1 test for test/Demo.t.sol:DemoTest
[PASS] testDemoTryCatch() (gas: 135554)
Traces:
  [135554] DemoTest::testDemoTryCatch() 
    ├─ [34473] → new DEMO_FALSE@0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06
    │   ├─ [335] DemoLib::forceFail(false) [delegatecall]
    │   │   └─ ← "force fail"
    │   └─ ← 155 bytes of code
    ├─ [0] VM::label(DEMO_FALSE: [0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06], DEMO_FALSE) 
    │   └─ ← ()
    ├─ [161] DEMO_FALSE::number() [staticcall]
    │   └─ ← 0
    ├─ [31888] → new DEMO_TRUE@0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63
    │   ├─ [236] DemoLib::forceFail(true) [delegatecall]
    │   │   └─ ← ()
    │   └─ ← 155 bytes of code
    ├─ [0] VM::label(DEMO_TRUE: [0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63], DEMO_TRUE) 
    │   └─ ← ()
    ├─ [161] DEMO_TRUE::number() [staticcall]
    │   └─ ← 24
    └─ ← ()

Test result: ok. 1 passed; 0 failed; finished in 430.28µs
Well break this down at a high level.
For the first case, we expect the DemoLib.forceFail() function to revert and for number to remain its default value of 0. We can confirm this is indeed what happens.
├─ [34473] → new DEMO_FALSE@0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06
│   ├─ [335] DemoLib::forceFail(false) [delegatecall]
│   │   └─ ← "force fail"
│   └─ ← 155 bytes of code
├─ [0] VM::label(DEMO_FALSE: [0xFEfC6BAF87cF3684058D62Da40Ff3A795946Ab06], DEMO_FALSE) 
│   └─ ← ()
├─ [161] DEMO_FALSE::number() [staticcall]
│   └─ ← 0
For the final case, we expect the DemoLib.forceFail() function to not revert and for number to be assigned the value of 24. We can also confirm that this is what happens.
├─ [31888] → new DEMO_TRUE@0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63
│   ├─ [236] DemoLib::forceFail(true) [delegatecall]
│   │   └─ ← ()
│   └─ ← 155 bytes of code
├─ [0] VM::label(DEMO_TRUE: [0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63], DEMO_TRUE) 
│   └─ ← ()
├─ [161] DEMO_TRUE::number() [staticcall]
│   └─ ← 24
That checks our final box ✅!
Wrapping Up
In summary, our four test cases tested both Solidity versions 0.8.20 and 0.8.21 and confirmed multiple new ways to exercise our immutable variables' new and improved flexibility within our smart contracts. While subtle, this update can introduce new use cases for Solidity immutables while also maintaining the variables immutability post-contract creation.
I hope you enjoyed this demo and as always, if you have any suggestions, comments, or requests for clarification, please do reach out.
If this made you want to throw money into a mostly empty pocket, please feel free to toss it here: 0x0b1928F5EbCFF7d9d2c8d72c608479d27117b14D.
If you're a LinkedIn connection master, please reach out to me on LinkedIn with a note from this article if you'd like to connect.
Final Test Code
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
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
Sources
Foundry book
Solidity docs
Solidity 0.8.21 Release Announcement