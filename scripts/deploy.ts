// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import ResourceTokenContract from "../contract-artifacts/ResourceToken.sol/ResourceToken.json";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  if (
    process.env.AVATAR_ADDRESS &&
    process.env.STONE_TOKEN_ADDRESS &&
    process.env.STICK_TOKEN_ADDRESS &&
    process.env.PLANT_TOKEN_ADDRESS &&
    process.env.APPLE_TOKEN_ADDRESS
  ) {
    const Wilderness = await ethers.getContractFactory("Wilderness");
    const wilderness = await Wilderness.deploy(
      process.env.AVATAR_ADDRESS,
      process.env.STONE_TOKEN_ADDRESS,
      process.env.STICK_TOKEN_ADDRESS,
      process.env.PLANT_TOKEN_ADDRESS,
      process.env.APPLE_TOKEN_ADDRESS
    );

    await wilderness.deployed();

    console.log("Wilderness deployed to:", wilderness.address);

    // Add Wilderness to MINTABLE role for each ResourceToken...
    const tokensToMint = [
      "STONE_TOKEN_ADDRESS",
      "STICK_TOKEN_ADDRESS",
      "PLANT_TOKEN_ADDRESS",
      "APPLE_TOKEN_ADDRESS",
    ];

    for (let i = 0; i < tokensToMint.length; i++) {
      const tokenAddress = process.env[tokensToMint[i]];
      if (tokenAddress) {
        const token = await ethers.getContractAt(
          ResourceTokenContract.abi,
          tokenAddress
        );
        const MINTER_ROLE = ethers.utils.keccak256(
          ethers.utils.toUtf8Bytes("MINTER_ROLE")
        );
        await token.grantRole(MINTER_ROLE, wilderness.address);
        console.log("Minter granted:", tokensToMint[i]);
      }
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
