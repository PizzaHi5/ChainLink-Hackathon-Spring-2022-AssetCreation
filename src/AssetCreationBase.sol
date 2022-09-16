//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";

//use is tokentimelock more in future
abstract contract AssetCreationBase is IERC20 {
    
    TokenTimelock internal TimeLock;
    address internal immutable assetUser;
    
    constructor (
        uint256 releaseTime,
        address beneficiary,
        address stakeholder,
        IERC20 _token
    ) {
        TimeLock = new TokenTimelock(_token, beneficiary, releaseTime);
        assetUser = stakeholder;
    }

    function user() public view virtual returns (address) {
        return assetUser;
    }
    
    function release() internal virtual {
        TimeLock.release();
    }
}   
