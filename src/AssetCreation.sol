//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AssetCreation {

    uint256 immutable duration;
    uint256 immutable startBlock;
    uint256 immutable endBlock;
    address immutable assetUser;
    //DAO vault to deploy, performs upkeep
    address constant vaultDAO = 0xeCf6d20544D0e84ca3Ab683F0394158E6c75eAaE; //get checksum'd address on Etherscan
    //address for holding tokens, change to immutable later
    address tokens;
    //maybe use ERC20/utils/TokenTimelock.sol with IERC20
    ERC20 private _tokens;
    //payable?
    address assetCreator;

    //DAO initalizes contract for known user
    constructor (
        uint256 amount,
        uint256 _duration,
        address user
    ) {
        duration = _duration;
        assetUser = user;
        startBlock = block.timestamp;
        endBlock = startBlock + duration;
        //intantiate new address for tokens 

        //fund contract
        //_tokens._beforeTokenTransfer(from, to, amount); ???
        _tokens.transferFrom(vaultDAO, tokens, amount);

    }

    function assignCreator (address _address) public view {
        require (checkIfInContract(msg.sender)); //add logic to check that assetCreator is not assigned yet
        assetCreator == _address;
    }

    function checkIfInContract (address _address) public view returns (bool) {
        
        if(_address == assetUser || _address == assetCreator){
            return true;
        } else {
            return false;
        }
    }

    function lockedTokens() public view returns (int256) {
        //return tokens.amount();
    }

    //calls end contract
    function callEndContract() public {
        require (checkIfInContract(msg.sender));
        endContract();
    }

    //checks if contract duration expired
    function checkUpkeep (bytes calldata) external view returns (
        bool upkeepNeeded) {
        upkeepNeeded = (block.timestamp >= endBlock);
    }

    //executes endContract 
    function performUpkeep(bytes calldata) external {
        if(block.timestamp >= endBlock){
            endContract();
        }
    }

    function endContract() internal {

        if(checkIfInContract(msg.sender)){
                //look at ERC20 transfer function
             if (block.timestamp >= endBlock) {
                 //send full amount to assetCreator
             } else if (block.timestamp >= (endBlock - duration)/2) {  //fix this logic
                 //send half amount to assetCreator
             } else {
                 //send initial contributed amount to assetUser minus fees,
                 //send crowdfunding amount to DAO fund
             }
        } else {
            //send full amount to asset Creator
        }
    }
}