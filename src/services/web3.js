/* eslint-disable camelcase */
import Web3 from 'web3';
import BigNumber from 'bignumber.js';

let web3;

export const initializeWeb3 = async () => {
  if (window.ethereum != null) {
    web3 = new Web3(window.ethereum);
    try {
      // Request account access if needed
      await window.ethereum.enable();
      // Acccounts now exposed
    } catch (error) {
      // User denied account access...
      console.log("denied", error)
    }
  } else {
    if (typeof web3 !== 'undefined') {
      console.warn("web3 not undefined")
      web3 = new Web3(web3.currentProvider);
    } else {
      console.warn("web3 undefined. setting to localhost")
      // set the provider you want from Web3.providers
      web3 = new Web3('http://localhost:8545');
    }
  }
}

export const getWeb3 = async () => {
  if (typeof web3 == 'undefined') {
    console.error("please init web3");
    return;;
  }

  return web3;
}

export const getBlockNumber = async () => {
  const latestBlockNumber = await web3.eth.getBlockNumber();
  return latestBlockNumber;
}