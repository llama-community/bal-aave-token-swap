// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
    OtcEscrowApprovals.sol is a fork of:
    https://github.com/fei-protocol/fei-protocol-core/blob/339b2f71e9fda31df628d5e17dd3e4482c91d088/contracts/utils/OtcEscrow.sol

    It uses only ERC20 approvals, without transfering any tokens to this contract as part of the swap.
    It assumes both parties have approved it to spend the appropriate amounts ahead of calling swap().

    To revoke the swap, any party can remove the approval granted to this contract and the swap will fail.
*/
contract OtcEscrowApprovals {
    using SafeERC20 for IERC20;

    address public immutable balancerDAO;
    address public immutable aaveDAO;

    address public immutable balToken;
    address public immutable aaveToken;

    uint256 public immutable balAmount;
    uint256 public immutable aaveAmount;

    bool public hasSwapOccured;

    event Swap(uint256 balAmount, uint256 aaveAmount);

    error SwapAlreadyOccured();

    constructor(
        address balancerDAO_,
        address aaveDAO_,
        address balToken_,
        address aaveToken_,
        uint256 balAmount_,
        uint256 aaveAmount_
    ) {
        balancerDAO = balancerDAO_;
        aaveDAO = aaveDAO_;

        balToken = balToken_;
        aaveToken = aaveToken_;

        balAmount = balAmount_;
        aaveAmount = aaveAmount_;
    }

    /// @dev Atomically trade specified amounts of BAL token and AAVE token
    /// @dev Anyone may execute the swap if sufficient token approvals are given by both parties
    function swap() external {
        // Check in case of infinite approvals and prevent a second swap
        if (hasSwapOccured) revert SwapAlreadyOccured();
        hasSwapOccured = true;

        // Transfer expected receivedToken from beneficiary
        IERC20(balToken).safeTransferFrom(balancerDAO, aaveDAO, balAmount);

        // Transfer sentToken to beneficiary
        IERC20(aaveToken).safeTransferFrom(aaveDAO, balancerDAO, aaveAmount);

        emit Swap(balAmount, aaveAmount);
    }
}
