// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {KryptoSignatures as UpgradeableKrypto} from "../src/Krypto.sol";

/**
 * @title KryptoSignatures Deployment Script (UUPS via ERC1967Proxy)
 * @notice Deploys upgradeable implementation and proxy, initializes the contract with name, symbol, and owner.
 */
contract KryptoScript is Script {
    // Token configuration
    string public constant TOKEN_NAME = "KryptoSignatures";
    string public constant TOKEN_SYMBOL = "KS";

    uint256 public constant INITIAL_MINT = 100_000_000_000 * 10 ** 18;

    // Deployed instances
    UpgradeableKrypto public kryptoImpl;
    UpgradeableKrypto public krypto; // proxy as Krypto

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // 1) Deploy implementation
        kryptoImpl = new UpgradeableKrypto();

        // 2) Deploy proxy for Krypto and initialize
        bytes memory kryptoInitData =
            abi.encodeWithSelector(UpgradeableKrypto.initialize.selector, TOKEN_NAME, TOKEN_SYMBOL, deployer);
        ERC1967Proxy kryptoProxy = new ERC1967Proxy(address(kryptoImpl), kryptoInitData);
        krypto = UpgradeableKrypto(payable(address(kryptoProxy)));

        // 3) Post-init configuration (optional)
        // 3a) Mint initial supply if needed
        if (INITIAL_MINT > 0) {
            krypto.mint(deployer, INITIAL_MINT);
        }

        vm.stopBroadcast();

        // Logs
        console.log("=== KryptoSignatures Deployment Complete ===");
        console.log("Deployer:", deployer);
        console.log("Krypto Impl:", address(kryptoImpl));
        console.log("Krypto Proxy:", address(krypto));
        console.log("Token Name:", TOKEN_NAME);
        console.log("Token Symbol:", TOKEN_SYMBOL);
        console.log("Owner:", krypto.owner());
        console.log("Total Supply:", krypto.totalSupply() / 10 ** 18);
        console.log("Max Supply:", krypto.MAX_SUPPLY() / 10 ** 18);
        (uint256 currentSupply, uint256 maxSupply, uint256 remainingSupply) = krypto.supplyInfo();
        console.log("Current Supply:", currentSupply / 10 ** 18);
        console.log("Remaining Supply:", remainingSupply / 10 ** 18);
        if (INITIAL_MINT > 0) {
            console.log("Treasury Balance:", krypto.balanceOf(deployer) / 10 ** 18);
        }
    }
}