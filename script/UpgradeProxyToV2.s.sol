// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/KryptoSignaturesV2.sol";

contract UpgradeProxy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        address v2ImplementationAddress = vm.envAddress("V2_IMPLEMENTATION_ADDRESS");
        
        console.log("========================================");
        console.log("Starting Proxy Upgrade");
        console.log("========================================");
        console.log("Proxy Address:", proxyAddress);
        console.log("New Implementation:", v2ImplementationAddress);
        console.log("Caller:", vm.addr(deployerPrivateKey));
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Get proxy contract
        KryptoSignaturesV2 proxy = KryptoSignaturesV2(proxyAddress);
        
        // Prepare initialization data for V2
        bytes memory initData = abi.encodeWithSelector(
            KryptoSignaturesV2.initializeV2.selector,
            "V2 Features Activated"
        );
        
        // Perform upgrade
        proxy.upgradeToAndCall(v2ImplementationAddress, initData);
        
        console.log("========================================");
        console.log("Upgrade Completed Successfully!");
        console.log("========================================");
        
        // Verify upgrade
        string memory version = proxy.version();
        string memory feature = proxy.newFeature();
        
        console.log("Contract Version:", version);
        console.log("New Feature:", feature);
        console.log("");
        
        vm.stopBroadcast();
    }
}