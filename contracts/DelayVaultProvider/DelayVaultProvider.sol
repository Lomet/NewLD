// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DelayVaultState.sol";

abstract contract DelayVaultProvider is DelayVaultState {
    constructor(address _token, ILockDealNFT _nftContract, ProviderData[] memory _providersData) {
        require(address(_token) != address(0x0), "invalid address");
        require(address(_nftContract) != address(0x0), "invalid address");
        require(_providersData.length <= 255, "too many providers");
        name = "DelayVaultProvider";
        Token = _token;
        lockDealNFT = _nftContract;
        typesCount = uint8(_providersData.length);
        uint256 limit = 0;
        for (uint8 i = 0; i < typesCount; i++) {
            limit = _setTypeToProviderData(i, limit, _providersData[i]);
        }
    }

    //params[0] = amount
    //params[1] = allowTypeChange, 0 = false, 1(or any) = true
    function registerPool(uint256 poolId, uint256[] calldata params) public override onlyProvider onlyProvider {
        uint256 amount = params[0];
        bool allowTypeChange = params[1] > 0;
        address owner = nftContract.ownerOf(poolId);
        require(params.length == 2, "invalid params length");
        _addHoldersSum(owner, amount, allowTypeChange);
        poolIdToAmount[poolId] = amount;
    }

    function getParams(uint256 poolId) external view override returns (uint256[] memory params) {
        params = new uint256[](2);
        params[0] = poolIdToAmount[poolId];
    }

    function getWithdrawableAmount(uint256 poolId) external view override returns (uint256 withdrawalAmount) {
        withdrawalAmount = poolIdToAmount[poolId];
    }

    function upgradeType(uint8 newType) public {
        uint8 oldType = UserToType[msg.sender];
        uint256 amount = _getTotalAmount(msg.sender);
        require(amount > 0, "amount must be bigger than 0");
        require(newType > oldType, "new type must be bigger than the old one");
        require(newType < typesCount, "new type must be smaller than the types count");
        UserToType[msg.sender] = newType;
    }

    function createNewDelayVault(address owner, uint256[] calldata params) external returns (uint256 PoolId) {
        uint256 amount = params[0];
        bool allowTypeChange = params[1] > 0;
        require(params.length == 2, "invalid params length");
        require(!allowTypeChange || _isAllowedChanheType(owner), "only owner can upgrade type");
        require(amount > 0, "amount must be bigger than 0");
        PoolId = nftContract.mintAndTransfer(owner, Token, msg.sender, amount, this);
        registerPool(PoolId, params);
    }

    function _isAllowedChanheType(address owner) internal view returns (bool) {
        return owner == msg.sender || lockDealNFT.approvedProviders(msg.sender);
    }
}
