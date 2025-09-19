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
