// SPDX-License-Identifier: MIT
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

    uint256 constant public _releaseTime= 100;
    uint256 constant public _amount = 1000;
    uint8 constant public _deadlineInterval = 4;
    address payable public _creator;
    IERC20 private tokens;

    function setUp() public {
        _creator = payable(0x1234567890123456789012345678901234567890);
        eg = new AssetCreationManualP2P(
            _releaseTime, 
            _amount, 
            _creator, 
            tokens, 
            _deadlineInterval);
        
        emit log_address(eg.getCreator());
        emit log("hello");
        emit log_named_address("Address: ", eg.getCreator());
    }

    function testReleaseTime() public {
        assertEq(_releaseTime, eg.getReleaseTime());
    }
    
    function testGetAmount() public {
        assertEq(_amount, eg.getAmount());
    }

    function testGetCreator() public {
        assertEq(_creator, eg.getCreator());
    }

    function testGetUser() public {
        assertEq(msg.sender, eg.getUser());
    }

    // All following tests fail if any of 4 tests above fail

    function testQuickEnd() public {
        cheats.warp(block.timestamp + 1);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), _amount/20);
        assertEq(tokens.balanceOf(eg.getUser()), (19*_amount)/20);
    }

    // Quarterly Ending
    function testFirstQuarterEnd() public {
        // 1st Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), _amount/4);
        assertEq(tokens.balanceOf(eg.getUser()), (3*_amount)/4);
    }

    function testSecondQuarterEnd() public {
        // 2nd Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), (2*_amount)/4);
        assertEq(tokens.balanceOf(eg.getUser()), (2*_amount)/4);
    }

    function testThirdQuarterEnd() public {
        // 3rd Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), (3*_amount)/4);
        assertEq(tokens.balanceOf(eg.getUser()), _amount/4);
    }

    function testFourthQuarterEnd() public {
        // 4th Interval
        cheats.warp(block.timestamp + 26);
        eg.releaseFunds();
        assertEq(tokens.balanceOf(eg.getCreator()), _amount);
    }
}