// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract TestERC20 is ERC20Permit {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) ERC20Permit(name_) {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
