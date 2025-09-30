
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
    
    event AssetCreated(uint256 indexed assetId, string name, address indexed owner);
    event AssetTransferred(uint256 indexed assetId, address indexed from, address indexed to);
    event AssetListed(uint256 indexed assetId, uint256 price);
    event AssetUnlisted(uint256 indexed assetId);
    event AssetPurchased(uint256 indexed assetId, address indexed from, address indexed to, uint256 price);
    
    // Core Function 1: Create Metaverse Asset
    function createAsset(
        string memory _name,
        string memory _description,
        string memory _metadataURI
    ) public returns (uint256) {
        uint256 assetId = _nextAssetId++;
        
        assets[assetId] = MetaverseAsset({
            id: assetId,
            name: _name,
            description: _description,
            owner: msg.sender,
            price: 0,
            isListed: false,
            metadataURI: _metadataURI
        });
        
        ownerAssets[msg.sender].push(assetId);
        
        emit AssetCreated(assetId, _name,_
