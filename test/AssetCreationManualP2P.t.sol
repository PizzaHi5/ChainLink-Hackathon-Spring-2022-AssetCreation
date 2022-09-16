// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/src/test.sol";
import "../src/AssetCreationManualP2P.sol";

interface CheatCodes {
    function warp(uint256) external;
}

contract AssetCreationManualP2PTest is DSTest {
    CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

    AssetCreationManualP2P private eg;

    uint256 constant _releaseTime= 100;
    uint8 constant _deadlineInterval = 4;
    address public _user = 0xeCf6d20544D0e84ca3Ab683F0394158E6c75eAaE; //vault address atm
    address public _creator = 0x1234567890123456789012345678901234567890; //put address here
    IERC20 private tokens;

    function setUp() public {
        eg = new AssetCreationManualP2P(_releaseTime, _creator, _user, tokens, _deadlineInterval);
    }

    function testuser() public {
        assertEq(_user, AssetCreationManualP2P.user);
    }

    function testCheckIfUser() public {
        assertEq(user, eg.getUser());
    }

    function testTimeRemaining() public view {
        eg.checkTimeRemaining();
    }

    function testEndContract() public {
        eg.endContract();
        assertEq(user.balanceOf(_user), )
        cheats.warp(block.timestamp + /3);
        eg.callEndContract();
        assertTrue(true);
        cheats.warp(block.timestamp + duration/2);
        eg.callEndContract();
        assertTrue(true);
    }
}
