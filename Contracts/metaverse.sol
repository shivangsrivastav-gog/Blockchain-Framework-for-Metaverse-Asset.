// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    struct MetaverseAsset {
        uint256 id;
        string name;
        string description;
        address owner;
        uint256 price;
        bool isListed;
        string metadataURI;
    }

    uint256 private _nextAssetId = 1;
    mapping(uint256 => MetaverseAsset) public assets;
    mapping(address => uint256[]) public ownerAssets;
    bool private locked; // for reentrancy guard

    // ===== Events =====
    event AssetCreated(uint256 indexed asset
