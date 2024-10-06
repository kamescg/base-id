// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

// Lib Imports
import "@openzeppelin/contracts/utils/Strings.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { CoinbaseSmartWallet } from "smart-wallet/src/CoinbaseSmartWallet.sol";

// Internal Imports
import { Router } from "./Router.sol";

contract Identity is Initializable {
    address public router;
    address public owner;

    error OffchainLookup(address sender, string[] urls, bytes callData, bytes4 callbackFunction, bytes extraData);

    constructor() { }

    function initialize(address _owner, address _router) external initializer {
        owner = _owner;
        router = _router;
    }

    function lookup() external view {
        bytes memory callData = abi.encodePacked(address(this));
        string[] memory urls_ = new string[](1);
        urls_[0] = Router(router).url();
        revert OffchainLookup(address(this), urls_, callData, this.resolve.selector, abi.encodePacked(owner));
    }

    function resolve(
        bytes calldata response,
        bytes calldata extraData
    )
        external
        view
        virtual
        returns (string memory did)
    {
        bytes memory msgSignature = response[0:65];
        bytes memory didHex = response[65:];
        address signer = _recoverSigner(string(didHex), msgSignature);
        address addr;
        assembly {
            // The offset of extraData in calldata
            let offset := extraData.offset
            // Load the first 32 bytes starting from offset
            let data := calldataload(offset)
            // Shift right by 12 bytes (96 bits) to get the address
            addr := shr(96, data)
        }
        CoinbaseSmartWallet(payable(addr)).isOwnerAddress(signer);
        return string(didHex);
    }

    function _recoverSigner(string memory message, bytes memory msgSignature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Correct message prefixing
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        bytes memory messageBytes = bytes(message);
        bytes memory messagePacked = abi.encodePacked(prefix, Strings.toString(messageBytes.length), message);
        bytes32 digest = keccak256(messagePacked);

        // Check the signature length
        if (msgSignature.length != 65) {
            return address(0);
        }

        // Divide the signature into r, s, and v variables
        assembly {
            r := mload(add(msgSignature, 32))
            s := mload(add(msgSignature, 64))
            v := byte(0, mload(add(msgSignature, 96)))
        }

        // Adjust v if needed
        if (v < 27) {
            v += 27;
        }

        // Recover the signer address
        return ecrecover(digest, v, r, s);
    }
}
