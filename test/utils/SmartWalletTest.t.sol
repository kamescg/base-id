// SPDX-License-Identifier: MIT AND Apache-2.0
pragma solidity 0.8.23;

import { Test } from "forge-std/src/Test.sol";
import { Vm } from "forge-std/src/Vm.sol";

struct TestUser {
    string name;
    address payable addr;
    uint256 privateKey;
}

struct TestUsers {
    TestUser alice;
    TestUser bob;
    TestUser carol;
    TestUser dave;
    TestUser eve;
    TestUser frank;
}

abstract contract SmartWalletTest is Test {
    TestUsers internal users;
    ////////////////////////////// Set Up //////////////////////////////

    function setUp() public virtual {
        // Create users
        users = _createUsers();
    }

    // Name is the seed used to generate the address, private key, and DeleGator.
    function createUser(string memory _name) public returns (TestUser memory user_) {
        (address addr_, uint256 privateKey_) = makeAddrAndKey(_name);
        vm.deal(addr_, 100 ether);
        vm.label(addr_, _name);

        user_.name = _name;
        user_.addr = payable(addr_);
        user_.privateKey = privateKey_;
    }

    ////////////////////////////// Private //////////////////////////////

    function _createUsers() private returns (TestUsers memory users_) {
        users_.alice = createUser("Alice");
        users_.bob = createUser("Bob");
        users_.carol = createUser("Carol");
        users_.dave = createUser("Dave");
        users_.eve = createUser("Eve");
        users_.frank = createUser("Frank");
    }
}
