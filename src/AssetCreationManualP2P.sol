//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AssetCreationManualP2P {
    using SafeERC20 for IERC20;
/*  Technical Description
This contract initalizes a Manual P2P asset creation stand-alone contract.

The core idea of this contract is to have the user initalize the contract by
supplying a ERC20 to a token address for holding. The user and the creator 
have the option to end the contract earlier from their initially supplied 
wallet addresses. At end term, the creator will pay gas to recieve the funds 
in the contract. 

    Simple Description
This creates a contract between 2 people. One person pays to create the contract 
and supplys the money (stakeholder), and the other pays to receive the money 
(benefitary). The contracts holds the money. Both people have the option to pay 
to end the contract early. 
*/
    uint8 private immutable deadlineInterval; //meant to be 2, 3, or 4
    uint256 private immutable releaseTime; //couldnt compare uint256 with function view returns (uint256)

    mapping (address => bool) public whiteList;
    mapping (bool => address) internal listWhite; 

    TokenTimelock public tokenTimeLock;

    constructor (
        uint256 _releaseTime,
        address _creator,
        IERC20 _tokens,
        uint8 _deadlineInterval
    ) {
        require(_creator != address(0), "ERC20:transfer from zero address");

        tokenTimeLock = new TokenTimelock(_tokens, _creator, _releaseTime);
        
        whiteList[payable(_creator)] = true;
        listWhite[whiteList[_creator]] = _creator;
        whiteList[payable(msg.sender)] = true;
        listWhite[!whiteList[msg.sender]] = msg.sender;
        deadlineInterval = _deadlineInterval;
        releaseTime = _releaseTime;
    }

    modifier onlyWhiteList {
        require(whiteList[msg.sender] == true, "Only WhiteList");
        _; //figure out why this is here in example
    }

    function startContract(uint256 _amount) payable public onlyWhiteList {
        require(_amount > 0, "Cannot transfer 0 or less");

        //Got to keep working on this
        tokenTimeLock.token().safeIncreaseAllowance(address(tokenTimeLock), _amount);
        tokenTimeLock.token().safeTransferFrom(getUser(), address(tokenTimeLock), _amount);        
    }

    function getUser() public view returns (address) {
        return listWhite[false];
    }
    
    function getCreator() public view returns (address) {
        return tokenTimeLock.beneficiary();
        //or listWhite[true];
    }

    function getAmount() public view returns (uint256) {
        return tokenTimeLock.token().balanceOf(address(tokenTimeLock));
    }
    
    function releaseFunds() public onlyWhiteList {
        
        if (block.timestamp > releaseTime) {
            releaseToCreator();

        // Four-Fold Deadlines
        } else if (deadlineInterval == 4) {

            if (block.timestamp > (3*releaseTime)/4) {
                //75% creator, 25% user
                releaseToUser(getAmount()/4);
                releaseToCreator();

            } else if (block.timestamp > (2*releaseTime)/4) {
                splitRelease();

            } else if (block.timestamp > (releaseTime)/4) {
                //25 creator, 75% user
                releaseToUser((3*getAmount())/4);
                releaseToCreator();

            } else {
                quickRelease();
            }

        // Three Fold Deadlines
        } else if (deadlineInterval == 3) {

            if (block.timestamp > (2*releaseTime)/3) {
                //66% creator, 33% user
                releaseToUser(getAmount()/3);
                releaseToCreator();

            } else if (block.timestamp > (releaseTime)/3) {
                // 33 creator, 66 user
                releaseToUser((2*getAmount())/3);
                releaseToCreator();

            } else {
                quickRelease();
            }

        // Two Fold Deadline
        } else if (deadlineInterval == 2) {

            if (block.timestamp > (releaseTime)/2) {
                splitRelease();

            } else {
                quickRelease();
            }
        } else {
            //can write custom intervals
        }
    }
    
    //Releases 95% to User, 5% to Creator from the contract vault
    function quickRelease () private {
        releaseToUser((19*getAmount())/20);
        releaseToCreator();
    }

    function splitRelease() private {
        releaseToUser(getAmount()/2);
        releaseToCreator();
    }

    function releaseToUser(uint256 amount) payable public onlyWhiteList {
        //transfer here
    }

    function releaseToCreator() payable public onlyWhiteList {
        tokenTimeLock.release();
    }

    function customRelease(uint256 creatorCut) private {
        //can write this
    }
}   