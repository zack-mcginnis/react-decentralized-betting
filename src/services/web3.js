/* eslint-disable camelcase */
import Web3 from "web3";
// import BigNumber from "bignumber.js";

let web3;

const initializeContract = () => {
  // Step 1: Get a contract into my application
  const json = require("../abi/BetCore.json");

  // Step 2: Turn that contract into an abstraction I can use
  const contract = require("@truffle/contract");
  const BetCore = contract(json);

  // Step 3: Provision the contract with a web3 provider
  BetCore.setProvider(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

  // Step 4: Use the contract!
  BetCore.deployed().then(function(deployed) {
    console.log(deployed);
  });
};

export const initializeWeb3 = async () => {
  if (window.ethereum != null) {
    web3 = new Web3(window.ethereum);
    try {
      // Request account access if needed
      await window.ethereum.enable();
      // Acccounts now exposed
    } catch (error) {
      // User denied account access...
      console.log("denied", error);
    }
  } else {
    if (typeof web3 !== "undefined") {
      console.warn("web3 not undefined");
      web3 = new Web3(web3.currentProvider);
    } else {
      console.warn("web3 undefined. setting to localhost");
      // set the provider you want from Web3.providers
      web3 = new Web3("http://localhost:8545");
    }
  }

  initializeContract();
};

export const getWeb3 = async () => {
  if (typeof web3 == "undefined") {
    console.error("please init web3");
    return;
  }

  return web3;
};

export const getBlockNumber = async () => {
  const latestBlockNumber = await web3.eth.getBlockNumber();
  return latestBlockNumber;
};