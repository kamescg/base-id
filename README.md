# Base ID

An experimental onchain decentralized identity system that auto-links Coinbase Smart Wallets to a Decentralized Identifier.

The system is designed to be fully decentralized and trustless with the help of the [EIP-3668](https://eips.ethereum.org/EIPS/eip-3668).

The prototype is lightweight and should probably stay that way--focusing only on the relationship between Smart Wallet and Decentralized Identifier.

Ideally there is only a single DID management service (i.e. Coinbase) that can provide a stable DID resolver and simple key rotation services.

But storage of attestations, proofs, authorizations, delegations, etc... can happen by any third party. As long as the root DID document points to signing keys that authorizes the data authenticity of those third-party sources.

It's cryptographic signatures from top-to-bottom, so really it doesn't matter who manages the DID resolver, because it's the User's signature that guarantees correctness.

## Getting Started

The Base ID smart contracts utilize [EIP-3668](https://eips.ethereum.org/EIPS/eip-3668) which means offchain data lookups.

Before running the tests you need to start the local server to handle requests from the smart contracts.

```sh
pnpm ts-node ./server/app.ts
```

The server will be running on `http://localhost:4200`.

After the server is running, you can run the tests:

```sh
forge test
```

## Usage

This is a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Format

Format the contracts:

```sh
$ forge fmt
```

## License

This project is licensed under MIT.
