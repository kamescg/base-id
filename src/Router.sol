// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

// Lib Imports
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { CoinbaseSmartWalletFactory } from "smart-wallet/src/CoinbaseSmartWalletFactory.sol";

// Internal Imports
import { Identity } from "./Identity.sol";

contract Router {
    string public url;
    address public immutable factory;
    address public immutable identityImpl;
    mapping(address wallet => address identity) public _identity;

    event IdentityCreated(address indexed wallet, address indexed identity, bytes[] indexed owners, uint256 nonce);

    constructor(address _factory, address _identityImpl, string memory _url) {
        factory = _factory;
        identityImpl = _identityImpl;
        url = _url;
    }

    function create(bytes[] calldata owners, uint256 nonce) external returns (address) {
        address wallet_ = CoinbaseSmartWalletFactory(factory).getAddress(owners, nonce);
        address instance = address(
            new ERC1967Proxy(
                address(identityImpl), abi.encodeWithSignature("initialize(address,address)", wallet_, address(this))
            )
        );

        _identity[wallet_] = instance;

        emit IdentityCreated(wallet_, instance, owners, nonce);
        return instance;
    }

    function identity(address wallet) external view returns (address) {
        return _identity[wallet];
    }

    function lookup(address wallet) external view returns (address) {
        Identity identity_ = Identity(_identity[wallet]);
        require(address(identity_) != address(0), "Router: identity not found");
        identity_.lookup();
    }
}
