//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.1;

import "hardhat/console.sol";
import "./MockResourceToken.sol";

contract Wilderness {
    MockResourceToken private stone;
    MockResourceToken private stick;
    MockResourceToken private plant;
    MockResourceToken private apple;

    constructor(
        address STONE_TOKEN_ADDRESS,
        address STICK_TOKEN_ADDRESS,
        address PLANT_TOKEN_ADDRESS,
        address APPLE_TOKEN_ADDRESS
    ) {
        stone = MockResourceToken(STONE_TOKEN_ADDRESS);
        stick = MockResourceToken(STICK_TOKEN_ADDRESS);
        plant = MockResourceToken(PLANT_TOKEN_ADDRESS);
        apple = MockResourceToken(APPLE_TOKEN_ADDRESS);
    }

    function forage() public {
        stone.mint(msg.sender, 8 ether);
        stick.mint(msg.sender, 10 ether);
        plant.mint(msg.sender, 5 ether);
        apple.mint(msg.sender, 2 ether);
    }
}
