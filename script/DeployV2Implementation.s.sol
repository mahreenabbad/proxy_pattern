// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/KryptoSignaturesV2.sol";

contract DeployV2Implementation is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("Deploying V2 Implementation...");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy new V2 implementation
        KryptoSignaturesV2 implementation = new KryptoSignaturesV2();
        
        console.log("========================================");
        console.log("V2 Implementation deployed at:", address(implementation));
        console.log("========================================");
        console.log("");
        console.log("IMPORTANT: Save this address!");
        console.log("Add to your .env file:");
        console.log("V2_IMPLEMENTATION_ADDRESS=", address(implementation));
        console.log("");
        
        vm.stopBroadcast();
        
        return address(implementation);
    }
}