// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { console2 } from "forge-std/src/console2.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Identity is Initializable {
    address public owner;

    string private _url;

    error OffchainLookup(address sender, string[] urls, bytes callData, bytes4 callbackFunction, bytes extraData);

    constructor(string memory __url) {
        _url = __url;
    }

    function initialize(address _owner) external initializer {
        owner = _owner;
    }


    function lookup() external view {
        bytes memory callData = abi.encodePacked(address(this));
        string[] memory urls_ = new string[](1);
        urls_[0] = _url;
        revert OffchainLookup(
            address(this),
            urls_,
            callData,
            this.resolve.selector,
            abi.encodePacked(address(this))
        );
    }

    function resolve(
        bytes calldata response,
        bytes calldata extraData
    )
        external
        view
        virtual
        returns (string memory DID)
    { 
        console2.logBytes(response);

    }
}
