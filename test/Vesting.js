const { assert } = require("chai");

const Token = artifacts.require("Token");
const Vesting = artifacts.require("Vesting");
const { time } = require("@openzeppelin/test-helpers");

contract("Vesting",(accounts) => {
    let token,vesting;
    before(async () => {
        console.log('deploying token contract')
        token = await Token.deployed();
        console.log('deploying vesting contract')
        vesting = await Vesting.deployed([accounts[1],accounts[2]],token.address);
        vesting.setPayee(accounts[1]);
        vesting.setPayee(accounts[2]);
    })
    
    const balance = web3.utils.toWei("100000000","ether")
    describe("in vesting contract",async () => {
        it("should return 100 million in balance",async() => {
            await token.approve(vesting.address, balance);
            await vesting.deposit();
            const result = await token.balanceOf(vesting.address);
            assert.equal(result.toString(),balance,"Contract balance is incorrect");
        })

        it("should return payees balance zero",async() => {
            const result1 = await token.balanceOf(accounts[1]);
            const result2 = await token.balanceOf(accounts[2]);
            const expected = 0;
            assert.equal(result1.toString(),expected.toString(),"Payee1 balance is incorrect");
            assert.equal(result2.toString(),expected.toString(),"Payee2 balance is incorrect")
        })

        it("should start vesting and return some  vested amount after 1 minute", async () => {
            await vesting.startVesting(31556926,60);
            await time.increaseTo(await time.latest() + time.duration.seconds(62));
            const result = await vesting.calculateTotalVestedAmount();
            const notExpected = 0;
            console.log(result.toString(),"vested amount after 1minute");
            assert.notEqual(result.toString(),notExpected.toString(),"Total vested amount is zero");
        })

        it("payee1 and payee2 should be eligible to release token",async() =>{
            var bool1 = await vesting.payees(accounts[1]);
            var bool2 = await vesting.payees(accounts[2]);
            assert.equal(bool1,true,"Not Eligible");
            assert.equal(bool2,true,"Not Eligible");
        })

        it("payee1 should be able to withdraw his vested amount in 1 minute",async() => {
            await vesting.release(accounts[1]);
            var result = (await vesting.tokenToBeReleased(accounts[1]));
            const value = 0;
            assert.equal(result.toString(),value.toString(),"Payee1 balance is inconrrect");
        })

        it("payee2 should be able to withdraw his vested amount in 1 minute",async() => {
            await vesting.release(accounts[2]);
            var result = (await vesting.tokenToBeReleased(accounts[2]));
            const value = 0;
            assert.equal(result.toString(),value.toString(),"Payee2 balance is inconrrect");
        })

        it("balance of contract should be changed after 1 min of release",async() => {
            await vesting.release(accounts[1]);
            await vesting.release(accounts[2]);
            const result = await token.balanceOf(vesting.address);
            assert.notEqual(result.toString(),balance,"Incorrect balance")
        })
    })  
})