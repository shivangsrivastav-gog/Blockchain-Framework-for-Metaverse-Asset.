// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Project - A simple marketplace for Metaverse assets
/// @notice Allows users to create, list, and buy unique digital assets securely
contract Project {
    // ====== Structs ======
    struct MetaverseAsset {
        uint256 id;
        string name;
        string description;
        address owner;
        uint256 price;
        bool isListed;
        string metadataURI;
    }

    // ====== State Variables ======
    uint256 private nextAssetId = 1;
    mapping(uint256 => MetaverseAsset) public assets;
    mapping(address => uint256[]) public ownerAssets;

    bool private reentrancyLock; // Reentrancy guard flag

    // ====== Events ======
    event AssetCreated(uint256 indexed assetId, string name, address indexed owner);
    event AssetListed(uint256 indexed assetId, uint256 price);
    event AssetTransferred(uint256 indexed assetId, address indexed from, address indexed to);

    // ====== Modifiers ======

    /// @dev Prevents reentrant function calls
    modifier nonReentrant() {
        require(!reentrancyLock, "Reentrancy not allowed");
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

    /// @dev Restricts function to asset owner only
    modifier onlyOwner(uint256 assetId) {
        require(assets[assetId].owner == msg.sender, "Caller is not asset owner");
        _;
    }

    // ====== Core Functions ======

    /// @notice Create a new Metaverse asset
    /// @param name The name of the asset
    /// @param description The description of the asset
    /// @param price The initial listing price
    /// @param metadataURI URI pointing to metadata (image, model, etc.)
    function createAsset(
        string memory name,
        string memory description,
        uint256 price,
        string memory metadataURI
    ) external nonReentrant {
        uint256 assetId = nextAssetId++;

        assets[assetId] = MetaverseAsset({
            id: assetId,
            name: name,
            description: description,
            owner: msg.sender,
            price: price,
            isListed: false,
            metadataURI: metadataURI
        });

        ownerAssets[msg.sender].push(assetId);

        emit AssetCreated(assetId, name, msg.sender);
    }

    /// @notice List an owned asset for sale
    /// @param assetId The ID of the asset
    /// @param price The desired sale price
    function listAsset(uint256 assetId, uint256 price)
        external
        onlyOwner(assetId)
        nonReentrant
    {
        MetaverseAsset storage asset = assets[assetId];
        require(!asset.isListed, "Asset already listed");

        asset.isListed = true;
        asset.price = price;

        emit AssetListed(assetId, price);
    }

    /// @notice Purchase a listed asset
    /// @param assetId The ID of the asset to buy
    function buyAsset(uint256 assetId) external payable nonReentrant {
        MetaverseAsset storage asset = assets[assetId];
        require(asset.isListed, "Asset not listed for sale");
        require(msg.value == asset.price, "Incorrect payment amount");

        address previousOwner = asset.owner;

        // Update ownership
        asset.owner = msg.sender;
        asset.isListed = false;
        ownerAssets[msg.sender].push(assetId);

        // Transfer payment
        payable(previousOwner).transfer(msg.value);

        emit AssetTransferred(assetId, previousOwner, msg.sender);
    }

    /// @notice Retrieve all asset IDs owned by a user
    /// @param user The address of the user
    /// @return Array of asset IDs
    function getOwnedAssets(address user) external view returns (uint256[] memory) {
        return ownerAssets[user];
    }
}
