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
    
    // Core Function 1: Create Metaverse Asset
    function createAsset(
        string memory _name,
        string memory _description,
        string memory _metadataURI
    ) public returns (uint256) {
        uint256 assetId = _nextAssetId;
        _nextAssetId++;
        
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
    
    // Core Function 2: Transfer Asset
    function transferAsset(uint256 _assetId, address _to) public {
        require(assets[_assetId].owner == msg.sender, "Not the asset owner");
        require(_to != address(0), "Invalid recipient address");
        require(_to != msg.sender, "Cannot transfer to yourself");
        
        address previousOwner = assets[_assetId].owner;
        assets[_assetId].owner = _to;
        assets[_assetId].isListed = false; // Remove from listing when transferred
        
        // Update owner arrays
        _removeAssetFromOwner(previousOwner, _assetId);
        ownerAssets[_to].push(_assetId);
        
        emit AssetTransferred(_assetId, previousOwner, _to);
    }
    
    // Core Function 3: List Asset for Sale
    function listAssetForSale(uint256 _assetId, uint256 _price) public {
        require(assets[_assetId].owner == msg.sender, "Not the asset owner");
        require(_price > 0, "Price must be greater than 0");
        
        assets[_assetId].price = _price;
        assets[_assetId].isListed = true;
        
        emit AssetListed(_assetId, _price);
    }

    // Core Function 4: Buy Asset
    function buyAsset(uint256 _assetId) public payable {
        MetaverseAsset storage asset = assets[_assetId];
        require(asset.isListed, "Asset is not listed for sale");
        require(msg.value >= asset.price, "Insufficient payment");
        require(msg.sender != asset.owner, "Owner cannot buy their own asset");

        address previousOwner = asset.owner;
        uint256 salePrice = asset.price;

        // Update ownership
        asset.owner = msg.sender;
        asset.isListed = false;
        asset.price = 0; // Reset price after purchase

        // Update ownerAssets mappings
        _removeAssetFromOwner(previousOwner, _assetId);
        ownerAssets[msg.sender].push(_assetId);

        // Transfer funds to seller
        payable(previousOwner).transfer(salePrice);

        emit AssetTransferred(_assetId, previousOwner, msg.sender);
    }
    
    // Additional helper functions
    function getAsset(uint256 _assetId) public view returns (MetaverseAsset memory) {
        return assets[_assetId];
    }
    
    function getOwnerAssets(address _owner) public view returns (uint256[] memory) {
        return ownerAssets[_owner];
    }
    
    function getAllListedAssets() public view returns (uint256[] memory) {
        uint256[] memory listedAssets = new uint256[](_nextAssetId - 1);
        uint256 counter = 0;
        
        for (uint256 i = 1; i < _nextAssetId; i++) {
            if (assets[i].isListed) {
                listedAssets[counter] = i;
                counter++;
            }
        }
        
        // Resize array to actual count
        uint256[] memory result = new uint256[](counter);
        for (uint256 i = 0; i < count
