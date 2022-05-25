//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

//use is tokentimelock more in future, ether.getERC20Interface(ierc20)
contract AssetCreation is KeeperCompatibleInterface {

    TokenTimelock private tokenTimeLock; //has IERC20, address benefitary, uint256 release time in seconds

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
    //0xeCf6d20544D0e84ca3Ab683F0394158E6c75eAaE; //get checksum'd address on Etherscan
    
    IERC20 public ierc20;
    
    //DAO initalizes contract for known user
    constructor (
        uint256 amount,
        uint256 _raisedAmount,
        address _user
    ) {
        // uncomment below b4 deploying
        //require (msg.sender == vaultDAO, "You are not the DAO"); 
        i_assetUser = _user;
        i_raisedAmount = _raisedAmount;
        ierc20.transferFrom(msg.sender, tokens, amount);
    }

    // called by user, duration in seconds
    function startContract (address _creatorAddr, uint256 _duration) public {
        //require (checkIfUser(msg.sender)); //add logic to check that assetCreator is not assigned yet
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
        //commented out for testing
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
                //use split tokens in future
             if (block.timestamp >= endTime - (duration/2)) {
                 ierc20.transfer(vaultDAO, i_raisedAmount/2);
                 ierc20.transfer(assetCreator, ierc20.balanceOf(tokens)/2);
                 ierc20.transfer(i_assetUser, ierc20.balanceOf(tokens));
             } else {
                 ierc20.transfer(vaultDAO, ((ierc20.balanceOf(tokens) - i_raisedAmount) / USER_PENALTY) + i_raisedAmount);
                 ierc20.transfer(i_assetUser, ierc20.balanceOf(tokens));
             }
        } else {
            //called by keeper
            ierc20.transfer(assetCreator, ierc20.balanceOf(tokens));
        }
    }
}