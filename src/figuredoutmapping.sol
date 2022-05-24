//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

//use is tokentimelock more in future, ether.getERC20Interface(_token)
contract AssetCreationMapping is KeeperCompatibleInterface {

    TokenTimelock private _tokenTimeLock; //has IERC20, address benefitary, uint256 release time in seconds

    struct Stats{
        address assetCreator;
        address assetUser;
    }
    mapping (address => Stats) public contractStats; //sweet got this working

    uint256 public duration;
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 constant USER_PENALTY = 10; // 10=10%, 20=5%, etc

    uint256 private immutable i_raisedAmount;

    address constant tokens = 0x096f6A2b185d63D942750A2D961f7762401cbA17; //change to a create a new ERC20 address
    
    address constant vaultDAO = 0xeCf6d20544D0e84ca3Ab683F0394158E6c75eAaE;
    //0xeCf6d20544D0e84ca3Ab683F0394158E6c75eAaE; //get checksum'd address on Etherscan
    
    IERC20 public _token;
    
    //DAO initalizes contract for known user
    constructor (
        uint256 amount,
        uint256 _raisedAmount,
        address _user
    ) {
        // uncomment below b4 deploying
        //require (msg.sender == vaultDAO, "You are not the DAO"); 
        contractStats[tokens].assetUser = _user;
        i_raisedAmount = _raisedAmount;
        //create new token address for contract
        //_token.transferFrom(msg.sender, tokens, amount);
    }

    // called by user
    function startContract (address _creatorAddr, uint256 _duration) public {
        //require (checkIfUser(msg.sender)); //add logic to check that assetCreator is not assigned yet
        contractStats[tokens].assetCreator = _creatorAddr;
        startBlock = block.timestamp;
        duration = _duration;
        endBlock = startBlock + _duration;
        //_tokenTimeLock = new TokenTimelock (ether.getERC20Interface(_token), _creatorAddr, endBlock);
    }

    function checkIfUser (address _userAddr) public view returns (bool) {
        require (_userAddr == contractStats[msg.sender].assetUser, "You are not responsible for this contract");
        return true;
    }

    function checkTimeRemaining () public view returns (uint256) {
        return endBlock - block.timestamp;
    }

    //calls end contract
    function callEndContract() public {
        require (checkIfUser(msg.sender), "You cannot end this contract");
        endContract();
    }

    //checks if contract duration expired
    function checkUpkeep (bytes calldata) external view returns (
        bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp >= endBlock);
    }

    //executes endContract 
    function performUpkeep(bytes calldata) external override {
        if(block.timestamp >= endBlock){
            endContract();
        }
    }

    function endContract() internal virtual {

        if(checkIfUser(msg.sender)){
                //use split tokens in future
             if (block.timestamp >= endBlock - (duration/2)) {
                 _token.transfer(vaultDAO, i_raisedAmount/2);
                 _token.transfer(contractStats[msg.sender].assetCreator, _token.balanceOf(tokens)/2);
                 _token.transfer(contractStats[msg.sender].assetUser, _token.balanceOf(tokens));
             } else {
                 _token.transfer(vaultDAO, ((_token.balanceOf(tokens) - i_raisedAmount) / USER_PENALTY) + i_raisedAmount);
                 _token.transfer(contractStats[msg.sender].assetUser, _token.balanceOf(tokens));
             }
        } else {
            //this will fail since msg.sender here is keeper?
             _token.transfer(contractStats[msg.sender].assetCreator, _token.balanceOf(tokens));
        }
    }

    function adding_value() public {
        
    }
}