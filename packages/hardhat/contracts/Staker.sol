// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;

    uint256 public deadline = block.timestamp + 6 days;

    bool public executed;

    bool public openForWithdraw;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier canStake() {
        require(block.timestamp < deadline, "should at stake state");
        _;
    }

    modifier canWithdraw() {
        require(openForWithdraw, "should at withdraw state");
        _;
    }

    modifier notCompleted() {
        require(!exampleExternalContract.completed(), "already completed");
        _;
    }

    event Stake(address indexed sender, uint256 value);

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable {
        ms1 = msg.sender;
        _stake(); // when `function stake()` invoke `function _stake(address,uint256)`, the msg.sender, msg.value ... dont change.
    }

    address public ms1;
    address public ms2;

    function _stake() internal canStake {
        address owner = msg.sender;
        uint256 value = msg.value;
        require(value > 0, "invalid value");
        balances[owner] += value;

        ms2 = msg.sender;

        emit Stake(owner, value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    // If the `threshold` was not met, allow everyone to call a `withdraw()` function
    function execute() public notCompleted {
        require(!executed, "already executed");
        require(block.timestamp > deadline, "stacking period, cannot execute");
        executed = true;

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
            require(
                exampleExternalContract.completed(),
                "fail to send to example external contract"
            );
        } else {
            openForWithdraw = true;
        }
    }

    // Add a `withdraw()` function to let users withdraw their balance
    function withdraw() public notCompleted canWithdraw {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No funds");

        delete balances[msg.sender];

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "refund failed");
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256 sec) {
        if (block.timestamp >= deadline) sec = 0;
        else sec = deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        _stake();
    }

    fallback() external payable {
        _stake();
    }
}
