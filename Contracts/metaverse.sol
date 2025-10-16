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
    bool private locked; // Reentrancy guard

    // ===== Events =====
    event AssetCreated(uint256 indexed assetId, string name, address indexed owner);
    event AssetListed(uint256 indexed assetId, uint256 price);
    event AssetTransferred(uint256 indexed assetId, address indexed from, address indexed to);

    // ===== Modifiers =====
    modifier nonReentrant() {
        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner(uint256 assetId) {
        require(assets[assetId].owner == msg.sender, "Not asset owner");
        _;
    }

    // ===== Functions =====

    /// @notice Create a new metaverse asset
    function createAsset(
        string memory name,
        string memory description,
        uint256 price,
        string memory metadataURI
    ) external nonReentrant {
        uint256 assetId = _nextAssetId++;

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
    function listAsset(uint256 assetId, uint256 price)
        external
        onlyOwner(assetId)
        nonReentrant
    {
        MetaverseAsset storage asset = assets[assetId];
        require(!asset.isListed, "Already listed");
        asset.isListed = true;
        asset.price = price;

        emit AssetListed(assetId, price);
    }

    /// @notice Buy a listed asset
    function buyAsset(uint256 assetId) external payable nonReentrant {
        MetaverseAsset storage asset = assets[assetId];
        require(asset.isListed, "Asset not listed");
        require(msg.value == asset.price, "Incorrect price");

        address previousOwner = asset.owner;

        // Transfer ownership
        asset.owner = msg.sender;
        asset.isListed = false;

        // Update owner assets mapping
        ownerAssets[msg.sender].push(assetId);

        // Transfer funds
        payable(previousOwner).transfer(msg.value);

        emit AssetTransferred(assetId, previousOwner, msg.sender);
    }

    /// @notice Get all asset IDs owned by a user
    function getOwnedAssets(address user) external view returns (uint256[] memory) {
        return ownerAssets[user];
    }
}
