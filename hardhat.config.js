// require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-deploy');

/** @type import('hardhat/config').HardhatUserConfig */
let secret = require("./secret");

module.exports = {
  solidity: "0.8.18",
  networks: {
    cerium: {
      url: 'https://cerium-rpc.canxium.net',
      accounts: [""],
      hardfork: "london"
    }
  },
  etherscan: {
    apiKey: {
      cerium: "abc"
    },
    customChains: [
      {
        network: "cerium",
        chainId: 30103,
        urls: {
          apiURL: "https://cerium-explorer.canxium.net/api",
          browserURL: "https://cerium-explorer.canxium.net"
        }
      }
    ]
  }
};