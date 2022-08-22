// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vesting is Ownable, ReentrancyGuard{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    mapping(address => uint) public totalTokenWithdrawn;
    mapping(address => bool) public payees;
    bool start = false;
    uint public startTime;
    uint public stopTime;
    uint public duration;
    uint public tokenToBeReleasedPerDuration;
    uint public payeesLength;
    address[] private payeesAddress;
    IERC20 token; 

    constructor(address[] memory _payees,address _token) {
        require(_payees.length > 0,"No Payees");
        require(_token != address(0x0));
        payeesLength = _payees.length;
        token = IERC20(_token);
        payeesAddress = _payees;
        for(uint i = 0; i < _payees.length; i++){
            payees[_payees[i]] = true;
        }
    }

    event VestingStarted(uint _startTime, uint _stopTime, uint _duration);
    event TokenReleased(uint _amount, address indexed payee);

    //12 Months - 31556926 in seconds
    //1 minute - 60 in seconds
    function startVesting(uint _stopTime,uint _duration) public onlyOwner {
        require(block.timestamp.add(_stopTime) > block.timestamp,"Stop time not accepted");
        require(_duration > 0,"Zero cannot be value");
        startTime = block.timestamp;
        stopTime = block.timestamp.add(_stopTime);
        duration = _duration;
        start = true;
        tokenToBeReleasedPerDuration = (token.balanceOf(address(this)).div(_stopTime)).mul(duration);
        emit VestingStarted(startTime, stopTime, duration);
    }

    function calculateTotalVestedAmount() public view returns(uint){
        require(start == true,"Vesting not started");
        uint time = block.timestamp;
        if(block.timestamp > stopTime){
            time = stopTime;
        }
        return(((time.sub(startTime)).div(60)).mul(tokenToBeReleasedPerDuration));
    }


    function release(address _payee) public nonReentrant{
        require(payees[_payee] == true,"Not Eligible");
        uint _amount = calculateTotalVestedAmount().div(payeesLength).sub(totalTokenWithdrawn[_payee]);
        totalTokenWithdrawn[_payee] = totalTokenWithdrawn[_payee].add(_amount);
        SafeERC20.safeTransfer(token, _payee, _amount);
        emit TokenReleased(_amount, _payee);
    }

    function tokenToBeReleased(address _payee) public view returns(uint){
        return(calculateTotalVestedAmount().div(payeesLength).sub(totalTokenWithdrawn[_payee]));
    }

    function deposit() payable public onlyOwner{
        SafeERC20.safeTransferFrom(token,msg.sender,address(this), token.balanceOf(msg.sender));
    }

    function checkBalance() public view returns(uint){
        return(token.balanceOf(address(this)));
    }

    function checkEligibleAddress() public view returns(address[] memory){
        return payeesAddress;
    }

    function setPayee(address _payee) public onlyOwner{
        payees[_payee] = true;
    }
}
//["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]