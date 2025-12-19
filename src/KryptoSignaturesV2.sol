// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./Krypto.sol";



/**
 * @title KryptoSignaturesV2
 * @dev Simple V2 upgrade - just adds a version function for testing
 */
contract KryptoSignaturesV2 is KryptoSignatures {
    // New storage variable (safe to add at the end)
    string public newFeature;

    /**
     * @dev V2 initializer
     */
    function initializeV2(string memory _newFeature) external reinitializer(2) {
        newFeature = _newFeature;
    }

    /**
     * @dev Returns the version of the contract
     */
    function version() external pure returns (string memory) {
        return "2.0.0";
    }

    /**
     * @dev New function in V2 - update the feature string
     */
    function updateFeature(string memory _newFeature) external onlyRole(DEFAULT_ADMIN_ROLE) {
        newFeature = _newFeature;
    }
}
