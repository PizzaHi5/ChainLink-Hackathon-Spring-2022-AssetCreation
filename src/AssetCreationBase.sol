//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

//use is tokentimelock more in future
abstract contract AssetCreationBase is KeeperCompatibleInterface, IERC20 {
    
    TokenTimelock internal TimeLock;
    address internal assetUser;

    IERC20 private _token;
    
    //Initalizing a stand-alone AssetCreation contract
    constructor (
        uint256 releaseTime,
        address beneficiary
    ) {
        TimeLock = new TokenTimelock(_token, beneficiary, releaseTime);
    }

    function setUser(address _assetUser) internal virtual {
        assetUser = _assetUser;
    }

    function user() public view virtual returns (address) {
        return assetUser;
    }
    
    function release() internal virtual {
        TimeLock.release();
    }

    function checkUpkeep(bytes calldata) external view virtual returns (
        bool upkeepNeeded, bytes memory performData) {}

    function performUpkeep(bytes calldata) external virtual {}
}   
