require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://127.0.0.1:7545", // Default URL for Ganache; adjust if needed for testing
      chainId: 1337 // Adjust if needed for testing
    }
  }
};
