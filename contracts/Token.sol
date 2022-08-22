// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("GameToken", "GTK") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }
}
