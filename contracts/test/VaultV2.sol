pragma solidity ^0.5.7;

import "../Basket.sol";
import "../Manager.sol";
import "../Vault.sol";
import "../rsv/IRSV.sol";

contract VaultV2 is Vault {

    function completeHandoff(address previousVaultAddress, Manager manager) external onlyOwner {
        Vault previousVault = Vault(previousVaultAddress);

        previousVault.acceptOwnership();

        previousVault.changeManager(address(this));

        // Transfer tokens from old vault to new vault.
        Basket trustedBasket = manager.trustedBasket();

        for (uint256 i = 0; i < trustedBasket.size(); i++) {
            address tok = trustedBasket.tokens(i);
            IERC20(tok).safeTransferFrom(
                previousVaultAddress,
                address(this),
                trustedBasket.weights(tok)
            );
            // unit check for amounts[i]: qToken.
        }

        // Point manager at the new vault.
        manager.setVault(address(this));

    }
}