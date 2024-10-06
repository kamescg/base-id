// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { console2 } from "forge-std/src/console2.sol";
import { CoinbaseSmartWallet } from "smart-wallet/src/CoinbaseSmartWallet.sol";
import { CoinbaseSmartWalletFactory } from "smart-wallet/src/CoinbaseSmartWalletFactory.sol";

import { Identity } from "../src/Identity.sol";
import { Router } from "../src/Router.sol";
import { SmartWalletTest } from "./utils/SmartWalletTest.t.sol";

contract RouterTest is SmartWalletTest {
    Identity internal identity;
    Router internal router;
    CoinbaseSmartWallet internal smartWalletImpl;
    CoinbaseSmartWalletFactory internal factory;

    function setUp() public virtual override {
        super.setUp();
        smartWalletImpl = new CoinbaseSmartWallet();
        factory = new CoinbaseSmartWalletFactory(address(smartWalletImpl));
        identity = new Identity("https://example.com");

        router = new Router(address(factory), address(identity));
    }

    /// @dev Basic test. Run it with `forge test -vvv` to see the console log.
    function test_Router_create() external {
        address[] memory owners = new address[](1);
        owners[0] = address(users.alice.addr);
        uint256 nonce = 1;
        address instance = router.create(owners, nonce);
    }

    // function testFork_Example() external {
    //     // Silently pass this test if there is no API key.
    //     string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
    //     if (bytes(alchemyApiKey).length == 0) {
    //         return;
    //     }

    //     // Otherwise, run the test against the mainnet fork.
    //     vm.createSelectFork({ urlOrAlias: "mainnet", blockNumber: 16_428_000 });
    //     address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    //     address holder = 0x7713974908Be4BEd47172370115e8b1219F4A5f0;
    //     uint256 actualBalance = IERC20(usdc).balanceOf(holder);
    //     uint256 expectedBalance = 196_307_713.810457e6;
    //     assertEq(actualBalance, expectedBalance);
    // }

}
