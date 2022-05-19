//SPDX license-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Creator is ERC20Votes {
    // 1 million tokens with 18 decimals
    uint256 public s_maxSupply = 1000000000000000000000000;

    constructor() 
    ERC20("Creator", "CTR")
    ERC20Permit("Creator"){
        _mint(msg.sender, s_maxSupply);
    }

    // the function below are overrides required by Solidity
    function _afterTokenTransfer(
        address from, 
        address to, 
        uint256 amount) 
    internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override (ERC20Votes){
        super._mint(to, amount);
    }

    function _burn (address account, uint256 amount) internal override (ERC20Votes){
        super._burn(account, amount);
    }


}