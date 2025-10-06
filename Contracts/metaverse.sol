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
        require(bytes(_name).length > 0, "Asset name required");
        require(bytes(_metadataURI).length > 0, "Metadata URI required");

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

        emit AssetCreated(assetId, _name, msg.sender);
        return assetId;
    }

    // Core Function 2: Transfer Ownership
    function transferAsset(uint256 _assetId, address _to) public {
        MetaverseAsset storage asset = assets[_assetId];
        require(asset.owner == msg.sender, "Only owner can transfer");
        require(_to != address(0), "Invalid recipient");

        _removeOwnerAsset(msg.sender, _assetId);
        asset.owner = _to;
        ownerAssets[_to].push(_assetId);

        emit AssetTransferred(_assetId, msg.sender, _to);
    }

    // Core Function 3: List Asset for Sale
    function listAsset(uint256 _assetId, uint256 _price) public {
        MetaverseAsset storage asset = assets[_assetId];
        require(asset.owner == msg.sender, "Only owner can list");
        require(_price > 0, "Price must be greater than zero");

        asset.isListed = true;
        asset.price = _price;

        emit AssetListed(_assetId, _price);
    }

    // Core Function 4: Unlist Asset
    function unlistAsset(uint256 _assetId) public {
        MetaverseAsset storage asset = assets[_assetId];
        require(asset.owner == msg.sender, "Only owner can unlist");

        asset.isListed = false;
        asset.price = 0;

        emit AssetUnlisted(_assetId);
    }

    // Core Function 5: Purchase Listed Asset
    function purchaseAsset(uint256 _assetId) public payable {
        MetaverseAsset storage asset = assets[_assetId];
        require(asset.isListed, "Asset not listed for sale");
        require(msg.value == asset.price, "Incorrect payment amount");
        require(msg.sender != asset.owner, "Owner cannot buy their own asset");

        address seller = asset.owner;
        payable(seller).transfer(msg.value);

        _removeOwnerAsset(seller, _assetId);
        asset.owner = msg.sender;
        asset.isListed = false;
        asset.price = 0;
        ownerAssets[msg.sender].push(_assetId);

        emit AssetPurchased(_assetId, seller, msg.sender, msg.value);
    }

    // Internal helper function: remove asset from owner’s list
    function _removeOwnerAsset(address _owner, uint256 _assetId) internal {
        uint256[] storage owned = ownerAssets[_owner];
        for (uint256 i = 0; i < owned.length; i++) {
            if (owned[i] == _assetId) {
                owned[i] = owned[owned.length - 1];
                owned.pop();
                break;
            }
        }
    }

    // View function: Get all assets owned by an address
    function getAssetsByOwner(address _owner) public view returns (uint256[] memory) {
        return ownerAssets[_owner];
    }
}
