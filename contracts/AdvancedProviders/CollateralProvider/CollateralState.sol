// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../SimpleProviders/LockProvider/LockDealState.sol";
import "./IInnerWithdraw.sol";

abstract contract CollateralState is LockDealState, IInnerWithdraw {
    function getParams(uint256 poolId) public view override returns (uint256[] memory params) {
        (, , uint256 mainCoinHolderId) = getInnerIds(poolId);
        if (lockDealNFT.exist(mainCoinHolderId)) {
            params = new uint256[](2);
            params[0] = provider.getParams(mainCoinHolderId)[0];
            params[1] = poolData[poolId][0];
        }
    }

    function getInnerIdsArray(uint256 poolId) public view override returns (uint256[] memory ids) {
        if (poolData[poolId].length > 0 && poolData[poolId][0] < block.timestamp) {
            ids = new uint256[](3);
            (ids[0], ids[1], ids[2]) = getInnerIds(poolId);
        } else {
            ids = new uint256[](2);
            (, ids[0], ids[1]) = getInnerIds(poolId);
        }
    }

    function currentParamsTargetLenght() public pure override(IProvider, ProviderState) returns (uint256) {
        return 2;
    }

    function getInnerIds(
        uint256 poolId
    ) internal pure returns (uint256 mainCoinCollectorId, uint256 tokenHolderId, uint256 mainCoinHolderId) {
        mainCoinCollectorId = poolId + 1;
        tokenHolderId = poolId + 2;
        mainCoinHolderId = poolId + 3;
    }

    function getWithdrawableAmount(uint256 poolId) public view override returns (uint256 withdrawalAmount) {
        if (lockDealNFT.poolIdToProvider(poolId) == this) {
            (uint256 mainCoinCollectorId, , uint256 mainCoinHolderId) = getInnerIds(poolId);
            withdrawalAmount = lockDealNFT.getWithdrawableAmount(mainCoinCollectorId);
            if (poolData[poolId].length > 0 && poolData[poolId][0] <= block.timestamp) {
                withdrawalAmount += lockDealNFT.getWithdrawableAmount(mainCoinHolderId);
            }
        }
    }

    ///@dev Collateral can't be Refundble or Bundleble
    /// Override basic provider supportsInterface
    function supportsInterface(bytes4 interfaceId) public view virtual override(BasicProvider) returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
