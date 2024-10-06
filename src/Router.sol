// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { CoinbaseSmartWalletFactory } from "smart-wallet/src/CoinbaseSmartWalletFactory.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Router {
    address public immutable factory;
    address public immutable identityImpl;

    event IdentityCreated(address indexed instance, address[] indexed owner, uint256 nonce);

    constructor(address _factory, address _identityImpl) {
        factory = _factory;
        identityImpl = _identityImpl;
    }

    function create(address[] calldata owners, uint256 nonce) external returns (address) {
        bytes[] memory owners_ = new bytes[](owners.length);
        for (uint256 i = 0; i < owners.length; i++) {
            owners_[i] = abi.encode(owners[i]);
        }

        address root_ = CoinbaseSmartWalletFactory(factory).getAddress(owners_, nonce);
        address instance = address(
            new ERC1967Proxy(
                address(identityImpl),
                abi.encodeWithSignature("initialize(address)", root_)
            )
        );

        emit IdentityCreated(instance, owners, nonce);
        return instance;
    }
}
