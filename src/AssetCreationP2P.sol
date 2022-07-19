//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "../src/AssetCreationBase.sol";

contract AssetCreationP2P is AssetCreationBase {
    
    //Initalizing a stand-alone P2P asset creation contract
    constructor (
        uint256 releaseTime,
        address beneficiary,
        address _user
    ) {
        AssetCreationBase.TimeLock = new TokenTimelock(_token, beneficiary, releaseTime);
        setUser(_user);
    }

    function setUser(address _assetUser) internal override {
        super(_assetUser);
    }

    function user() public view virtual returns (address) {
        super();
    }
    
    function release() internal virtual {
        TimeLock.release();
    }

    function checkUpkeep(bytes calldata) external view virtual returns (
        bool upkeepNeeded, bytes memory performData) {}

    function performUpkeep(bytes calldata) external virtual {}
}   
