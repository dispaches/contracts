require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
const PRIVATE_KEY = process.env.PRIVATE_KEY || "key";
const SCROLL_RPC_URL = process.env.SCROLL_RPC_URL || "https://eth-sepolia";
const SCROLLSCAN_API_KEY = process.env.SCROLL_SCAN;

module.exports = {
  solidity: "0.8.0",

  networks: {
    sepolia: {
      url: SCROLL_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 534352,
    },
  },

  scrollscan: {
    apikey: SCROLLSCAN_API_KEY,
  },
};
