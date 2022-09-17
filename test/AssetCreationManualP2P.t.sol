// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/src/test.sol";
import "../src/AssetCreationManualP2P.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface CheatCodes {
    function warp(uint256) external;
}

contract AssetCreationManualP2PTest is DSTest {
    CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

    AssetCreationManualP2P private eg;

    uint256 constant _releaseTime= 100;
    uint256 constant _amount = 1000;
    uint8 constant _deadlineInterval = 4;
    address public _user;
    address public _creator = 0x1234567890123456789012345678901234567890; //put address here
    IERC20 private tokens;

    function setUp() public {
        eg = new AssetCreationManualP2P(
            _releaseTime, 
            _amount, 
            _creator, 
            tokens, 
            _deadlineInterval);
    }

    function testCheckVariables() public {
        assertEq(_releaseTime, eg.getReleaseTime());
        assertEq(_amount, eg.getAmount());
        assertEq(_creator, eg.getCreator());
        assertEq(msg.sender, eg.getUser());
    }

    function testEndContract() public {
        //Quick End
        cheats.warp(block.timestamp + 1);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), _amount/20);
        assertEq(tokens.balanceOf(eg.getUser()), (19*_amount)/20);

        //Quarterly Interval End
        //  1st Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), _amount/4);
        assertEq(tokens.balanceOf(eg.getUser()), (3*_amount)/4);

        //  2nd Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), (2*_amount)/4);
        assertEq(tokens.balanceOf(eg.getUser()), (2*_amount)/4);

        //  3rd Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), (3*_amount)/4);
        assertEq(tokens.balanceOf(eg.getUser()), _amount/4);
        
        //  4th Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), _amount);
    }
}
