//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.1;

import "hardhat/console.sol";
import "./MockResourceToken.sol";
import "./MockERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Wilderness is IERC721Receiver {
    // Contracts
    MockResourceToken private stone;
    MockResourceToken private stick;
    MockResourceToken private plant;
    MockResourceToken private apple;

    MockERC721 private avatar;

    // Tracking avatarOwners[msg.sender] => array of their tokenIDs
    mapping(address => uint256[]) public avatarOwners;

    // Tracking activeForagers[tokenId] ==> foraging details
    mapping(uint256 => ForagingRecord) public activeForagers;
    struct ForagingRecord {
        uint256 duration; // seconds
        uint256 startTime;
        bool collected; // false at start, true when collect
    }

    event ForageStarted(
        address owner,
        uint256 tokenId,
        uint256 startTime,
        uint256 duration
    );
    event ForageComplete(
        address owner,
        uint256 stoneQty,
        uint256 stickQty,
        uint256 plantQty,
        uint256 appleQty
    );

    constructor(
        address AVATAR_ADDRESS,
        address STONE_TOKEN_ADDRESS,
        address STICK_TOKEN_ADDRESS,
        address PLANT_TOKEN_ADDRESS,
        address APPLE_TOKEN_ADDRESS
    ) {
        avatar = MockERC721(AVATAR_ADDRESS);
        stone = MockResourceToken(STONE_TOKEN_ADDRESS);
        stick = MockResourceToken(STICK_TOKEN_ADDRESS);
        plant = MockResourceToken(PLANT_TOKEN_ADDRESS);
        apple = MockResourceToken(APPLE_TOKEN_ADDRESS);
    }

    function startForage(uint256 tokenId) public {
        uint256 duration = 5 * 60; // 5 minutes, hard-coded just for now...
        // TODO it should be variable
        // and there should be some kinda lookup table dealie to figure out reward modifiers
        avatar.safeTransferFrom(msg.sender, address(this), tokenId);
        activeForagers[tokenId] = ForagingRecord(
            duration,
            block.timestamp,
            false
        );
        avatarOwners[msg.sender].push(tokenId);
        emit ForageStarted(msg.sender, tokenId, block.timestamp, duration);
    }

    function completeForage(uint256 tokenId) public {
        require(
            block.timestamp >
                activeForagers[tokenId].startTime +
                    activeForagers[tokenId].duration,
            "Foraging not yet complete"
        );

        uint8 tokenIdIndex;
        bool ownsAvatar = false;
        for (uint8 i = 0; i < avatarOwners[msg.sender].length; i++) {
            if (avatarOwners[msg.sender][i] == tokenId) {
                tokenIdIndex = i;
                ownsAvatar = true;
                break;
            }
        }
        require(ownsAvatar, "Must own Avatar to collect");

        avatar.safeTransferFrom(address(this), msg.sender, tokenId);
        uint256 stoneQty = 8 ether;
        uint256 stickQty = 10 ether;
        uint256 plantQty = 5 ether;
        uint256 appleQty = 2 ether;
        stone.mint(msg.sender, stoneQty);
        stick.mint(msg.sender, stickQty);
        plant.mint(msg.sender, plantQty);
        apple.mint(msg.sender, appleQty);
        activeForagers[tokenId].collected = true;

        avatarOwners[msg.sender][tokenIdIndex] = avatarOwners[msg.sender][
            avatarOwners[msg.sender].length - 1
        ];
        avatarOwners[msg.sender].pop();

        emit ForageComplete(msg.sender, stoneQty, stickQty, plantQty, appleQty);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        tokenId;
        data;
        return IERC721Receiver.onERC721Received.selector;
    }

    function getOwnedAvatars(address owner)
        public
        view
        returns (uint256[] memory)
    {
        return avatarOwners[owner];
    }
}
