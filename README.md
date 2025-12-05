## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

////
//load env, evry time open a new teminal
source .env

//cost estimation without broadcast
forge script script/Counter.s.sol --rpc-url $RPC_URL

/// DEPLOy with verify

forge script script/Deploy.s.sol \
 --rpc-url $RPC_URL \
 --broadcast \
 --verify \
 --etherscan-api-key $ETHERSCAN_API_KEY \
 --private-key $PRIVATE_KEY

///////////
KryptoSignatures Implementation: 0xd7E309243609042924d15B941F6c2eC3aDCA710a
KryptoSignatures Proxy: 0x01810F3d048a39Cfe15143D526F42Ba5c731f3d1
KryptoSignatures deployed successfully!

//////////////
//check layout
forge inspect ContractName storage-layout

/// deploy implementation v2
forge script script/DeployKryptoSignaturesV2.s.sol:DeployKryptoSignaturesV2 --rpc-url $RPC_URL --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY --private-key $PRIVATE_KEY

///////////////////////
