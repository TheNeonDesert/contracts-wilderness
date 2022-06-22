import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.1", // TODO make all contracts fixed to a specific Solidity version, right?
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.RINKEBY_ALCHEMY_API_KEY}`,
      accounts: [
        process.env.RINKEBY_PRIVATE_KEY ? process.env.RINKEBY_PRIVATE_KEY : "",
      ],
    },
    harmonyTestnet: {
      url: `https://api.s0.b.hmny.io`,
      accounts: [
        process.env.HARMONY_PRIVATE_KEY ? process.env.HARMONY_PRIVATE_KEY : "",
      ],
    },
    harmonyDevnet: {
      url: `https://api.s0.ps.hmny.io`,
      accounts: [
        process.env.HARMONY_PRIVATE_KEY ? process.env.HARMONY_PRIVATE_KEY : "",
      ],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
