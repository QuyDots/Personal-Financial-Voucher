require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

function accountsFromEnv(key) {
  if (!key) return [];
  return [key];
}

module.exports = {
  solidity: "0.8.20",
  networks: (() => {
    const networks = {
      localhost: {
        url: process.env.LOCALHOST_RPC || "http://127.0.0.1:8545",
      },
    };

    const sepoliaUrl = process.env.RPC_URL || process.env.SEPOLIA_RPC_URL;
    if (sepoliaUrl) {
      networks.sepolia = {
        url: sepoliaUrl,
        chainId: 11155111,
        accounts: accountsFromEnv(process.env.PRIVATE_KEY),
      };
    }

    const cronosUrl = process.env.CRONOS_TESTNET_RPC;
    if (cronosUrl) {
      networks.cronosTestnet = {
        url: cronosUrl,
        chainId: 338,
        accounts: accountsFromEnv(process.env.CRONOS_TESTNET_PRIVATE_KEY),
      };
    }

    return networks;
  })(),
};
