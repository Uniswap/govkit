// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";

import {Recorder} from "src/forge/Recorder.sol";
import {ChainId} from "src/constants/ChainId.sol";

// forge script script/RecorderExample.sol:RecorderExample

contract Counter {
    uint256 public count;

    function increment() public {
        count += 1;
    }
}

contract RecorderExample is Script {
    Recorder internal recorder;
    function run() external {

        // Initialize the Recorder.
        //
        recorder.initialize({
            scriptName: "Example",
            debugMode: true
        });

        // Deploy the contract & record it.
        //
        address counter = recorder.write(
            ChainId.Ethereum,
            "Counter", 
            address(new Counter())
        );

        // Check the record exists.
        require(recorder.exists(ChainId.Ethereum, "Counter"), "Counter not found.");

        // Load the contract's address.
        //
        address loadedCounter = recorder.read(ChainId.Ethereum, "Counter");

        // Check they're the same.
        //
        require(counter == loadedCounter);

        // (Optional): Clear the record.
        //
        recorder.clear();
    }
}
