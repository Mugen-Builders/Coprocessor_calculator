// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std-1.9.6/src/Script.sol";
import "../src/Calculator.sol";

contract Deploy is Script {
    /// @notice Simple deploy script to deploy the solidity contract contained in MyContract.sol
    /// @dev Replace the first deployment argument with the address of the coprocessor task issues for deployment chain
    /// @dev Replace the second deployment argument with the machine has for the cartesi backend code whose execution you intend to run.
    function run() external {
        vm.startBroadcast();
        new Calculator(
            address(0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf),
            hex"a01fc6a52602f3cb018b952b1c383d873241ae2c746adf38b14800ebae667f82"
        );
        vm.stopBroadcast();
    }
}
