// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract DZBToken is ERC20, ERC20Permit {
    constructor() ERC20("DZBToken", "DZB") ERC20Permit("DZBToken") {
        _mint(msg.sender, 500000 * 10 ** decimals());
    }
}
