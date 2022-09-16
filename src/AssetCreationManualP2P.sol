//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "../src/AssetCreationBase.sol";

contract AssetCreationManualP2P is AssetCreationBase {
    
/*  Technical Description
This contract initalizes a Manual P2P asset creation stand-alone contract 
The core idea of this contract is to have the user initalize the contract by
supplying USDC to a token address for holding using their gas. The user
and the creator have the option to end the contract earlier from their
initially supplied wallet addresses paying gas. At end term, the creator 
will pay gas to recieve the funds in the contract. 

    Simple Description
This creates a contract between 2 people. One person pays to create the contract 
and supplys the money (stakeholder), and the other pays to recieve the money 
(benefitary). The contracts holds the money. Both people have the option to pay 
to end the contract early. 
*/
    uint8 private immutable deadlineInterval;
    uint256 private immutable startTime;
    address payable private immutable creator;
    address payable user;

    constructor (
        uint256 releaseTime,
        address payable _creator,
        address _user,
        IERC20 _tokens,
        uint8 _deadlineInterval
    ) {
        AssetCreationBase.TimeLock = new TokenTimelock(_tokens, _creator, releaseTime);
        AssetCreationBase.assetUser = msg.sender; //change this to this.address cuz instantiating pty is user
        deadlineInterval = _deadlineInterval;
        startTime = block.timestamp;
    }

    function user() public view override returns (address) {
        super.user();
    }
    
    function release() internal override {
        super.release();
    }
}   
