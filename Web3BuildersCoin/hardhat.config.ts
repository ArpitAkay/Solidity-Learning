import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const privateKey =
  "d5e47a6832c0c6d0ace07ce495616eea5a174dd16333b8963e07c5431fce2022";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {},
    sepolia: {
      url: "https://sepolia.infura.io/v3/<key>",
      accounts: [privateKey],
    },
  },
};

export default config;
