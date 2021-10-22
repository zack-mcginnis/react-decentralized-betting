

# Solidity Contracts
This project contains solidity contract files which allow users to risk Ether on the outcome of  various sporting events.  The users are matched with each other by choice; users can create a wager and wait for another user to accept it, or they can accept an already created wager. Game scores are provided by an oracle service (Oraclize) which queries a trusted datasource (TBD).  In the future, a decentralize oracle solution, such as Chainlink, would be optimal 
## Using Truffle
Install Truffle
```sh
npm install -g truffle
```
then run:
```sh
truffle install
```
NOTE: if you are using Windows, you may have to run Truffle commands using `truffle.cmd` rather than `truffle`..
For example, the previous command would be `truffle.cmd install` on Windows, compared to `truffle install` on other platforms.


## Running a local network (Ganache, formerly testRPC)
Download, install, and run [Ganache](http://truffleframework.com/ganache/).
Ganache will open a private testnet on localhost:7545 by default

## Using Ethereum-Bridge (for Oraclize) (only necessary with bet-core contract)
Oraclize provides nodes for mainnet, and the Ropsten/Rinkeby testnets.  However, their testnet deployments are not always reliable and can be hard to work with. Typically, we cannot use Oraclize with a private local testnet since we have no way to access the Oraclize smart contract.  Luckily, we can use Ethereum-Bridge to act as a bridge between an Oraclize contract and our local testnet.

To set up ethereum-bridge, simply: 
```sh
git clone https://github.com/oraclize/ethereum-bridge
```
Then,
```sh
cd ethereum-bridge
npm install
```
At this point, ensure that Ganache (or some other private testnet) is running at localhost:7545 (or whichever port is specified).
Then run:
```sh
node bridge -H localhost:7545 -a 9
```
This will use account 10 (accounts[9]) from the list of accounts created by Ganache.  
NOTE: do not use this account (account [9]) to deploy your contracts.

After this command has completed, you will see a line which looks like:
```sh
Please add this line to your contract constructor:
OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
```

Copy and paste this line at the top of the BetCore constructor within BetCore.sol

These commands will create a bridge between Oraclize and your private test network.
From here, we can run `truffle migrate --reset --compile-all --network ganache` (using an account other than [9]) to deploy our contract to the network.
This command will compile and migrate our deployment to the specified network (ganache). Note that this command will re-compile all contract code and reset all previous migrations each time you run it.

In your `truffle.js` file, you should edit the `ganache` object and change the `from` property to the address of the account you wish to deploy from (again, not [9]). By default, it is set to account[1] in Ganache.

From here, you can interact with your contract via the truffle-cli, or you can link your testnet url to remix and interact with it from there.

## Using Truffle to deploy to Rinkeby, Ropsten testnets
Ensure the latest version of geth is installed on your local machine.
Navigate to the directory where you wish to store chain data, and run:
```sh
geth --datadir=./chaindata --rinkeby --fast --rpc --rpcapi db,eth,net,web3,personal
```
While geth is syncing, in the same directory, run:
```sh
geth attach geth.ipc
```
This will launch a console in which you can create/import/unlock accounts.
Visit [go-ethereum](https://github.com/ethereum/go-ethereum/wiki/Managing-your-accounts) to create or import, and then unlock your account.
Visit the [Rinkeby test faucet](https://faucet.rinkeby.io/) to fund your accounts with Ether.
Once the sync is complete, you will be able to run `truffle compile --network rinkeby` and `truffle migrate --network rinkeby` to compile and deploy your contracts.
Note: do not forgot to update all of your local `truffle.js` files to set the `from` property to the address you want to use to deploy the contract.

# Other options

## Using Remix
For quick testing and development of contracts, Remix IDE is also a great tool to use [Remix](remix.ethereum.org)

### MetaMask
Add all .sol files contained within `contracts` to the Remix project browser panel.
If you are using MetaMask and want to test the contracts using your MetaMask accounts, Remix should find the injected Web3
and list it as your current environment.

Within MetaMask, I recommend Ropsten as the testnet of choice. The Ether faucet is easy and simple to use, and transactions are relatively fast.
When running Ganache, you will need to add the local network address under the 'Custom RPC' tab within MetaMask.

### Javascript VM
If you want to test the contracts via Javascript VM, you can also select that option from environments.
NOTE: The Oraclize API will not work when using the Javascript VM.

### To Deploy
Select the `BetCore.sol` contract from the project browser panel.  On the right hand panel (above the pink 'create' button), choose 'BetCore' from the dropdown, and hit the 'create' button. Accept the transaction within the MetaMask plugin, and the contract collection will be deployed!

# TESTING WITH TRUFFLE
If you haven't already make sure you connect Ethereum-Bridge for Oraclize (instructions are listed above).
Once you have copied over the `addressOfToken`, and updated the OAR variable from Ethereum-Bridge, run `truffle migrate --reset --compile-all --network ganache` in the project directory.
At this point, you should be able to run `truffle test` from the same directory.

# Getting Started with Create React App

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Available Scripts

In the project directory, you can run:

### `yarn start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.\
You will also see any lint errors in the console.

### `yarn test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `yarn build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `yarn eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).
