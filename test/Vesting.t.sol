// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Vesting.sol";
import "../contracts/Token.sol";

contract TestVesting{
    Token public token;
    Vesting public vesting;

    address public address1 = address(0x031A0823dC77D9db80b37d8971bB71C58FA01Ba6);
    address public address2 = address(0xDc746E9300bF152BC003133077A6b36edC1f8E37);

    function beforeEach() public{
        address[] memory payee = new address[](2);
        payee[0] = address1;
        payee[1] = address2;
        token = new Token();
        vesting = new Vesting(payee,address(token));
    }

    function testingInitialBalanceOfVestingContract() public{

        uint expected = 100000000 * 10 ** 18;
        token.approve(address(vesting), expected);
        vesting.deposit();
        Assert.equal(token.balanceOf(address(vesting)),expected,"Contract balance is incorrect");
    }

    function testingInitialBalanceOfPayees() public{
        uint expected = 0;
        Assert.equal(token.balanceOf(address1),expected,"Balance is incorrect");
        Assert.equal(token.balanceOf(address2),expected,"Balance is incorrect");
    }
}