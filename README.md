### ArdManualBridge
---
# Project Overview

---

## Technical Requirement
 - Smart Contracts are written with Solidity language.
 - Smart Contracts mostly uses OpenZeppelin Contracts.
 - Smart Contracts follow the Natspec Format.
 - Smart Contracts must be written with full flexibility.
 - Solidity compiler version 0.8.20 is used.
 - Using the Hardhat development framework.
 - Using the hardhat-abi-exporter plugin for ABI export when smart contracts compiled.
 - Smart contracts are designed to be deployed to EVM Chains.
    - ArdCoinManualBridgeLocker smart contract designed to be deployed to Ethereum.
    - ArdCoinManualBridgeMinter smart contract designed to be deployed to any EVM chain other than Ethereum.

---

## Deployment flow
 1. Copy .env-example file and rename it to .env
 2. Set owner account PRIVATE KEY on env file
 3. Run the deployment script

---

## Functionality Requirement

### ArdCoinManualBridgeLocker
 - Will have token main chain lock and unlock business logic.

### ArdCoinManualBridgeMinter
 - Will have token destination chain mint and burn business logic.

### Roles
 - Pauser : Can pause/unpause ArdCoinManualBridgeMinter,ArdCoinManualBridgeLocker smart contracts core features
 - Locker : Can use ArdCoinManualBridgeLocker smart contract , lock functionality
 - Unlocker : Can use ArdCoinManualBridgeLocker smart contract , unlock functionality
 - Minter : Can use ArdCoinManualBridgeMinter smart contract , mint functionality
 - Burner : Can use ArdCoinManualBridgeMinter smart contract , burn functionality
 - Admin : Can update roles and access roles such as PAUSER/LOCKER/UNLOCKER of ArdCoinManualBridgeMinter and PAUSER/MINTER/BURNER of ArdCoinManualBridgeLocker smart contracts

### ArdCoinManualBridgeLocker features
 - Lock Role can lock tokens
 - Unlock Role can unlock tokens
 - Admin can update roles and access core functionalities such as lock/unlock
 - Pauser Role can pause lock/unlock functionalities
 - TokenLocked event will be used to know when and how much tokens were locked
 - TokenUnlocked event will be used to know when and how much tokens were unlocked

### ArdCoinManualBridgeMinter Features
 - Minter Role can mint tokens
 - Burner Role can burn tokens 
 - Admin can update roles and access core functionalities such as mint/burn
 - Pauser Role can pause mint/burn functionalities
 - TokenMinted event will be used to know when and how much tokens were minted
 - TokenBurned event will be used to know when and how much tokens were burned

---

## Getting Started
---
Recommended Node version is 16.0.0 and above.

### Available commands
```

# install dependencies
$ npm install

# run tests
$ npm run test

# compile contracts & generate ABI and Typescript types
$ npm run compile

# check test coverage
$ npm run coverage

# force compile contracts & generate ABI and Typescript types
$ npm run force-compile

# deploy contracts locally
$ npm run deploy-local

# deploy contracts to ganache
$ npm run deploy-ganache

# deploy contracts to bsc
$ npm run deploy

# deploy contracts to testnet bsc
$ npm run deploy-test

```

## Project Structure
---
This a template hardhat javascript project composed of contracts, tests, and deploy instructions that provides a great starting point for developers to quickly get up and running and deploying smart contracts on the Ethereum blockchain.

### Tests
---
Tests are found in the ./test/ folder.

### Contracts
---
Solidity smart contracts are found in ./contracts/

### Coverage
---
Coverages are generated after running the "npm run coverage" command

### ABI
---
Solidity smart contracts ABI's are generated in ./abi/ when contracts are compiled.

### Deploy
---
Deploy script can be found in the ./scripts/deployment.ts.

Rename ./.env.example to ./.env in the project root. To add the private key of a deployer account, assign the environment variables.

```
# deploy contracts locally
$ npm run deploy-local

# deploy contracts to ganache
$ npm run deploy-ganache

# deploy contracts to bsc
$ npm run deploy

# deploy contracts to testnet bsc
$ npm run deploy-test
```

---
