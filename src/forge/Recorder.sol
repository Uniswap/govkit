// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {vm} from "src/forge/Constants.sol";
import {console} from "lib/forge-std/src/console.sol";
import {VmSafe} from "lib/forge-std/src/Vm.sol";

struct Recorder {
    string scriptName;
    bool debugMode;
    bool initialized;
}

using LibRecorder for Recorder global;

library LibRecorder {
    string internal constant defaultName = "Default";
    string internal constant directory = ".records/";

    function initialize(Recorder storage recorder, string memory scriptName) internal {
        recorder.initialize({scriptName: scriptName, debugMode: false});
    }

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

    function write(Recorder storage recorder, string memory deploymentName, address deployment)
        internal
        returns (address)
    {
        return recorder.write(vm.getChainId(), deploymentName, deployment);
    }

    function write(Recorder storage recorder, uint256 chainId, string memory deploymentName, address deployment)
        internal
        returns (address)
    {
        require(
            recorder.initialized,
            "Recorder::Error: Recorder not initialized. " "Has `recorder.initialize()` been called?"
        );

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

    function path(Recorder storage recorder) internal view returns (string memory) {
        return string.concat(directory, recorder.scriptName, ".json");
    }
}
