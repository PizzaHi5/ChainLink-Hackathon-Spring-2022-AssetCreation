//SPDX License Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";

contract AssetCreationManualP2P {
    
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
    uint8 private immutable deadlineInterval; //meant to be 2, 3, or 4
    uint256 private immutable releaseTime; //couldnt compare uint256 with function view returns (uint256)
    address payable private immutable user;
    address payable private immutable holdingAddress; //got to figure this out
    address private USDCaddress = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    TokenTimelock internal tokenTimeLock;

    constructor (
        uint256 _releaseTime,
        uint256 amount,
        address _creator,
        IERC20 _tokens,
        uint8 _deadlineInterval
    ) {
        require(_creator != address(0), "ERC20:transfer from zero address");
        tokenTimeLock = new TokenTimelock(_tokens, _creator, _releaseTime);
        user = payable(msg.sender);
        deadlineInterval = _deadlineInterval;
        releaseTime = _releaseTime;
        require(amount > 0, "Cannot transfer less than 0");
        //trying to instantiate a new USDC address for holding tokens
        //unique to this contract
        _tokens.transferFrom(user, holdingAddress, amount);
        
    }

    function getUser() public view returns (address) {
        return user;
    }
    
    function getCreator() public view returns (address) {
        return tokenTimeLock.beneficiary();
    }

    function getToken() public view returns (IERC20) {
        return tokenTimeLock.token();
    }

    function getReleaseTime() public view returns (uint256) {
        return tokenTimeLock.releaseTime();
    }

    function getAmount() public view returns (uint256) {
        return tokenTimeLock.token().balanceOf(address(this));
    }
    
    function releaseFunds() private {
        
        if (block.timestamp > releaseTime) {
            tokenTimeLock.release();

        // Quarterly Deadlines
        } else if (deadlineInterval == 4) {

            if (block.timestamp > (3*releaseTime)/4) {
                //75% creator, 25% user
                tokenTimeLock.token().transferFrom(holdingAddress, tokenTimeLock.beneficiary(), (3*getAmount())/4);
                tokenTimeLock.token().transferFrom(holdingAddress, user, getAmount());

            } else if (block.timestamp > (2*releaseTime)/4) {
                // 50/50
            } else if (block.timestamp > (releaseTime)/4) {
                //25 creator, 75% user
            } else {
                quickRelease();
            }

        // Three Fold Deadlines
        } else if (deadlineInterval == 3) {

            if (block.timestamp > (2*releaseTime)/3) {
                //66% creator, 33% user
            } else if (block.timestamp > (releaseTime)/3) {
                // 33 creator, 66 user
            } else {
                quickRelease();
            }

        // Two Fold Deadline
        } else if (deadlineInterval == 2) {

            if (block.timestamp > (releaseTime)/2) {
                //50% creator, 50% user
            } else {
                quickRelease();
            }
        } else {
            //can write custom intervals
        }
    }

    function quickRelease () private {
        //5% creator, 95% user
    }

    function customRelease(uint256 creatorCut) private {
        
    }
}   
