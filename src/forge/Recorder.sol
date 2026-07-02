// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {vm} from "./Constants.sol";
import {console} from "forge-std/console.sol";
import {VmSafe} from "forge-std/Vm.sol";

/// @dev Recorder Type
struct Recorder {
    /// @dev Name of the Script from which this executes.
    string scriptName;
    /// @dev If true, use excessive logging.
    bool debugMode;
    /// @dev If true, then `recorder.initialize()` has been called.
    bool initialized;
}

using LibRecorder for Recorder global;

/// @title Persistent Contract Recorder
/// @dev Records contract addresses with their network & name to a JSON file for
///      subsequent script runs. This is for scripts which must be run
///      separately from one another but addresses from deployed contracts in
///      prior scripts must be referenced in subsequent scripts. We map this
///      in `.records/<script_name>.json` structured as
///      `<chain_id>.<name>.<address>`.
/// @dev We use excessive logging if `debugMode` is on, as Foundry's native API
///      for file-based I/O is unintuitive and clunky. This makes debugging the
///      issues, if any, with recording things to disk.
library LibRecorder {
    /// @dev Default script name if none is provided.
    string internal constant defaultName = "Default";

    /// @dev Directory name in which records are written.
    string internal constant directory = ".records/";

    /// @dev Initializes the Recorder without debug mode.
    /// @param recorder The recorder in the Script/Test contract's state.
    /// @param scriptName Name of the script in which the relevant contract is deployed.
    function initialize(Recorder storage recorder, string memory scriptName) internal {
        recorder.initialize({scriptName: scriptName, debugMode: false});
    }

    /// @dev Initializes the Recorder.
    /// @param recorder The recorder in the Script/Test contract's state.
    /// @param scriptName Name of the script in which the relevant contract is deployed.
    /// @param debugMode If true, uses excessive logging for debugging purposes.
    function initialize(Recorder storage recorder, string memory scriptName, bool debugMode) internal {
        recorder.scriptName = scriptName;
        recorder.debugMode = debugMode;

        if (bytes(recorder.scriptName).length == 0) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug: scriptName is empty; using scriptName=\"Default\"");
            }

            recorder.scriptName = defaultName;
        }

        recorder.checkDirectoryPermissions();

        if (!vm.isDir(directory)) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug:", directory, "does not exist; creating.");
            }

            vm.createDir(directory, false);

            if (recorder.debugMode) {
                console.log("Recorder::Debug:", directory, "created");
            }
        }

        string memory filePath = recorder.path();

        if (!vm.isFile(filePath)) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug:", filePath, "does not exist; writing \"{}\" to ", filePath);
            }

            vm.writeJson("{}", filePath);

            if (recorder.debugMode) {
                console.log("Recorder::Debug:", filePath, ": wrote \"{}\"");

                console.log("Recorder::Debug: no addresses loaded.");
            }
        }

        recorder.initialized = true;
    }

    /// @dev Write a contract name to disk with current chain ID.
    /// @param recorder The recorder in the Script/Test contract's state.
    /// @param deploymentName Name of the contract to record.
    /// @param deployment Address to be recorded.
    function write(Recorder storage recorder, string memory deploymentName, address deployment)
        internal
        returns (address)
    {
        return recorder.write(vm.getChainId(), deploymentName, deployment);
    }

    /// @dev Write a contract name to disk.
    /// @param recorder The recorder in the Script/Test contract's state.
    /// @param chainId Chain ID to record to.
    /// @param deploymentName Name of the contract to record.
    /// @param deployment Address to be recorded.
    function write(Recorder storage recorder, uint256 chainId, string memory deploymentName, address deployment)
        internal
        returns (address)
    {
        require(
            recorder.initialized,
            "Recorder::Error: Recorder not initialized. " "Has `recorder.initialize()` been called?"
        );
        require(bytes(deploymentName).length > 0, "Recorder::Error: deploymentName is empty.");

        string memory deploymentString = vm.toString(deployment);
        string memory filePath = recorder.path();

        try vm.writeJson(deploymentString, filePath, string.concat(vm.toString(chainId), ".", deploymentName)) {
            if (recorder.debugMode) {
                console.log(
                    string.concat(
                        "Recorder::Debug: ", filePath, ": wrote {\"", deploymentName, "\" : \"", deploymentString, "\"}"
                    )
                );
            }
        } catch (bytes memory revertData) {
            console.log(
                "Recorder::Error: vm.writeJson failed. This is likely because the"
                "file does not exist or does not at least contain \"{}\"."
            );
            revert(string.concat("Forge VM Error:", abi.decode(revertData, (string))));
        }

        return deployment;
    }

    /// @dev Read a contract from disk.
    /// @param recorder The recorder in the Script/Test contract's state.
    /// @param chainId Chain ID to read from.
    /// @param deploymentName Name of the contract to read.
    /// @return Address read.
    function read(Recorder storage recorder, uint256 chainId, string memory deploymentName)
        internal
        view
        returns (address)
    {
        require(
            recorder.initialized,
            "Recorder::Error: Recorder not initialized. " "Has `recorder.initialize()` been called?"
        );

        string memory filePath = recorder.path();
        string memory json;

        try vm.readFile(filePath) returns (string memory innerJson) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug:", filePath, "read");
            }

            json = innerJson;
        } catch (bytes memory revertData) {
            console.log("Recorder::Error: Unknown Forge Error.");

            revert(string.concat("Forge VM Error: ", abi.decode(revertData, (string))));
        }

        string memory key = string.concat(".", vm.toString(chainId), ".", deploymentName);

        try vm.parseJsonAddress(json, key) returns (address deployment) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug: parsed", deployment);
            }

            return deployment;
        } catch (bytes memory revertData) {
            console.log("Recorder::Error: vm.parseJsonAddress failed. This is likely " "because the JSON is malformed");
            revert(string.concat("Forge VM Error:", abi.decode(revertData, (string))));
        }
    }

    /// @dev Check if a contract exists on disk.
    /// @dev This IS NOT required before `read()`, this is for conditional deployments.
    /// @param recorder The recorder in the Script/Test contract's state.
    /// @param chainId Chain ID to read from.
    /// @param deploymentName Name of the contract to read.
    /// @return If true, the address exists.
    function exists(Recorder storage recorder, uint256 chainId, string memory deploymentName)
        internal
        view
        returns (bool)
    {
        require(
            recorder.initialized,
            "Recorder::Error: Recorder not initialized. " "Has `recorder.initialize()` been called?"
        );

        string memory filePath = recorder.path();
        string memory json;

        try vm.readFile(filePath) returns (string memory innerJson) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug:", filePath, "read");
            }

            json = innerJson;
        } catch (bytes memory revertData) {
            console.log("Recorder::Error: Unknown Forge Error.");

            revert(string.concat("Forge VM Error: ", abi.decode(revertData, (string))));
        }

        string memory key = string.concat(".", vm.toString(chainId), ".", deploymentName);

        return vm.keyExistsJson(json, key);
    }

    /// @dev Clear a record file if it exists on disk, otherwise does nothing.
    /// @param recorder The recorder in the Script/Test contract's state.
    function clear(Recorder storage recorder) internal {
        require(
            recorder.initialized,
            "Recorder::Error: Recorder not initialized. " "Has `recorder.initialize()` been called?"
        );

        if (!vm.isDir(directory)) {
            if (recorder.debugMode) {
                console.log("Recorder::Debug:", directory, "not found; nothing to clear");
            }
            return;
        }

        if (recorder.debugMode) {
            console.log("Recorder::Debug:", directory, "removing");
        }

        vm.removeDir(directory, true);

        if (recorder.debugMode) {
            console.log("Recorder::Debug:", directory, "removed");
        }
    }

    /// @dev Internal path construction for the recorder's script name.
    function path(Recorder storage recorder) internal view returns (string memory) {
        return string.concat(directory, recorder.scriptName, ".json");
    }

    /// @dev Internal check if the recorder has file permissions.
    function checkDirectoryPermissions(Recorder storage) internal view {
        try vm.isDir(directory) returns (bool) {}
        catch (bytes memory revertData) {
            console.log(
                string.concat(
                    "Recorder::Error: vm.isDir smoke check failed. This is likely due " "to missing file permissions.\n"
                    "Does `foundry.toml` contain: " "`fs_{ access = \"read-write\", path = \"",
                    directory,
                    "\"",
                    " }`?\n"
                )
            );

            revert(string.concat("Forge VM Error: ", abi.decode(revertData, (string))));
        }
    }
}
