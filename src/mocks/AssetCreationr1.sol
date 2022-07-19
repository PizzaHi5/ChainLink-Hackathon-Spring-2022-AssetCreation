//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

//use is tokentimelock more in future
contract AssetCreation is KeeperCompatibleInterface {

    TokenTimelock private tokenTimeLock;

    uint256 private duration;
    uint256 private startTime;
    uint256 private endTime;
    uint256 constant USER_PENALTY = 10; // 10=10%, 20=5%, etc

    uint256 private immutable i_raisedAmount;
    address private immutable i_assetUser;

    address payable private tokens;

    //payable?
    address private assetCreator;
    
    address constant vaultDAO = 0xeCf6d20544D0e84ca3Ab683F0394158E6c75eAaE;
    
    IERC20 public ierc20;
    
    //DAO initalizes contract for known user
    constructor (
        uint256 amount,
        uint256 _raisedAmount,
        address _user
    ) {
        //require (msg.sender == vaultDAO, "You are not the DAO"); 
        i_assetUser = _user;
        i_raisedAmount = _raisedAmount;
        //I need to learn how to do transfers properly
        //ierc20.transferFrom(vaultDAO, tokens, amount);
    }

    // called by user, duration in seconds
    function startContract (address _creatorAddr, uint256 _duration) public {
        //change to msg.sender
        (checkIfUser(i_assetUser)); //add logic to check that assetCreator is not assigned yet
        assetCreator = _creatorAddr;
        startTime = block.timestamp;
        duration = _duration;
        endTime = startTime + _duration;
        tokenTimeLock = new TokenTimelock (ierc20, _creatorAddr, endTime);
    }

    function checkIfUser (address _userAddr) public view returns (bool) {
        if (_userAddr == i_assetUser) {
            return true;
        } else {
            return false;
        }
    }

    function getUser () public view returns (address) {
        return i_assetUser;
    }

    function getCreator () public view returns (address) {
        return assetCreator;
    }

    function checkTimeRemaining () public view returns (uint256) {
        return endTime - block.timestamp;
    }

    //calls end contract
    function callEndContract () public {
        //change to msg.sender
        require (checkIfUser(i_assetUser), "You cannot end this contract");
        endContract(true);
    }

    //checks if contract duration expired
    function checkUpkeep (bytes calldata) external view returns (
        bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp >= endTime);
    }

    //executes endContract 
    function performUpkeep(bytes calldata) external override {
        if(block.timestamp >= endTime) {
            endContract(false);
        }
    }

    function endContract(bool _isUser) internal virtual {

        if(_isUser) {
                //use split tokens in future?
             if (block.timestamp >= endTime - (duration/2)) {
                 //ierc20.transfer(assetCreator, ierc20.balanceOf(tokens)/2);
                 //ierc20.transfer(i_assetUser, ierc20.balanceOf(tokens));
             } else {
                 //ierc20.transfer(vaultDAO, ((ierc20.balanceOf(tokens) - i_raisedAmount) / USER_PENALTY) + i_raisedAmount);
                 //ierc20.transfer(i_assetUser, ierc20.balanceOf(tokens));
             }
        } else {
            //called by keeper, need to figure out how txs work
            //bool sentTx = ierc20.transferFrom(tokens,assetCreator,ierc20.balanceOf(tokens)); ???
        }
    }
}