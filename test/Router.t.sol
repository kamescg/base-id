// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

// Testing Imports
import { console2 } from "forge-std/console2.sol";
import { Surl } from "surl/src/Surl.sol";
import { stdJson } from "forge-std/StdJson.sol";

// Lib Imports
import { CoinbaseSmartWalletFactory } from "smart-wallet/src/CoinbaseSmartWalletFactory.sol";
import { CoinbaseSmartWallet } from "smart-wallet/src/CoinbaseSmartWallet.sol";

// Internal Imports
import { Identity } from "../src/Identity.sol";
import { Router } from "../src/Router.sol";
import { SmartWalletTest } from "./utils/SmartWalletTest.t.sol";

contract RouterTest is SmartWalletTest {
    using Surl for *;
    using stdJson for string;

    CoinbaseSmartWallet internal smartWalletImpl;
    CoinbaseSmartWalletFactory internal factory;

    Identity internal identity;
    Router internal router;

    string document = "{id: did:base:metasudo }";

    function setUp() public virtual override {
        super.setUp();
        smartWalletImpl = new CoinbaseSmartWallet();
        factory = new CoinbaseSmartWalletFactory(address(smartWalletImpl));

        identity = new Identity();
        router = new Router(address(factory), address(identity), "http://localhost:4200/{sender}");
    }

    function test_E2E() external {
        bytes[] memory owners = new bytes[](1);
        owners[0] = abi.encode(users.alice.addr);
        uint256 nonce = 1;
        address wallet = address(factory.createAccount(owners, nonce));
        address instance = router.create(owners, nonce);
        Identity idInstance = Identity(instance);

        // Sign the decentralized identity document and send it to the server
        bytes memory signature = signMessage(document, users.alice.privateKey);
        string[] memory headers = new string[](1);
        headers[0] = "Content-Type: application/json";
        string memory message = string.concat(
            "{",
            '"address": "',
            vm.toString(instance),
            '",',
            '"document": "',
            document,
            '",',
            '"signature": "',
            vm.toString(signature),
            '"}'
        );
        "http://localhost:4200/write".post(headers, message);

        // Resolve DID Document using the Identity Contract
        try idInstance.lookup() { }
        catch (bytes memory revertData) {
            uint256 offset = 4;
            uint256 len = revertData.length - offset;
            bytes memory data;
            assembly {
                data := add(revertData, offset)
                mstore(data, len)
            }
            (
                address sender,
                string[] memory urls,
                bytes memory callData,
                bytes4 callbackFunction,
                bytes memory extraData
            ) = abi.decode(data, (address, string[], bytes, bytes4, bytes));

            // Fetch the document from the URL
            string memory urlFormatted = buildURL(urls[0], instance);
            (uint256 resStatus, bytes memory resData) = urlFormatted.get();

            // Finish resolving the document i.e. verify the signature
            string memory documentResolve = idInstance.resolve(_hexStringToBytes(string(resData)), extraData);
            assertEq(document, documentResolve, "Document should be resolved and verified");
        }

        // Resolve DID Document using the Router and Smart Wallet
        try router.lookup(address(wallet)) { }
        catch (bytes memory revertData) {
            uint256 offset = 4;
            uint256 len = revertData.length - offset;
            bytes memory data;
            assembly {
                data := add(revertData, offset)
                mstore(data, len)
            }
            (
                address sender,
                string[] memory urls,
                bytes memory callData,
                bytes4 callbackFunction,
                bytes memory extraData
            ) = abi.decode(data, (address, string[], bytes, bytes4, bytes));

            // Fetch the document from the URL
            string memory urlFormatted = buildURL(urls[0], instance);
            (uint256 resStatus, bytes memory resData) = urlFormatted.get();

            // Finish resolving the document i.e. verify the signature
            string memory documentResolve = idInstance.resolve(_hexStringToBytes(string(resData)), extraData);
            assertEq(document, documentResolve, "Document should be resolved and verified");
        }
    }
}
