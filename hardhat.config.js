require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require('dotenv').config()

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const GET_BLOCK_BSC_TESTNET = process.env.GET_BLOCK_BSC_TESTNET;
const GET_BLOCK_BSC_MAINNET = process.env.GET_BLOCK_BSC_MAINNET;
const PRIVATE_KEY_1 = process.env.PRIVATE_KEY_1;
const PRIVATE_KEY_2 = process.env.PRIVATE_KEY_2;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.2",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.8.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.8.15",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
      {
        version: "0.7.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 500,
          },
        },
      },
    ],
  },
  networks: {
    ganache: {
      url: "http://127.0.0.1:8545",
      accounts: [
        "0x78a9e6792b45ea79a9faaa9915795992ddf0c82f0e354d6971f7c73fe9b62be7",
        "0x891350a5bfeed0c9399e7dd488b6d3719098b02bd9a709d870a20a2fd2918ab8"
      ]
    },
    ganacheui: {
      url: "http://127.0.0.1:7545",
      accounts: {
        mnemonic: "horn green raccoon journey galaxy annual peasant pulp dose spirit wrestle magic",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        passphrase: "",
      },
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY_1, PRIVATE_KEY_2],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY_1, PRIVATE_KEY_2],
    },
    bsctestnet: {
      url: `https://go.getblock.io/${GET_BLOCK_BSC_TESTNET}`,
      accounts: [PRIVATE_KEY_1, PRIVATE_KEY_2],
    },
    bscmainnet: {
      url: `https://go.getblock.io/${GET_BLOCK_BSC_MAINNET}`,
      accounts: [PRIVATE_KEY_1, PRIVATE_KEY_2],
    },
    ethmainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY_1, PRIVATE_KEY_2],
    }
  },
};
