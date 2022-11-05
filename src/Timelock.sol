// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Timelock {
    // Custom errors
    error InsufficientFunds();
    error LockTimeStillActive();
    error TransferFailed();

    //  Amount deposited is mapped to the user address
    mapping(address => uint256) public balances;

    // Time of withdraw is mapped to user address
    mapping(address => uint256) public unlockTime;

    function deposit() external payable {
        // Update balance and set unlocktime
        // Unchecked logic because both values are unlikely to overflow

        balances[msg.sender] += msg.value;
        unlockTime[msg.sender] += 1 weeks;
    }

    function increaseLockTime(uint256 _secondsToIncrease) public {
        // Adds provided amount of time to unlock time
        unlockTime[msg.sender] = unlockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        // Check that the sender has ether deposited in the contract and that the balance is greater than zero
        if (balances[msg.sender] == 0) {
            revert InsufficientFunds();
        }

        //Check that the current timestamp is greater than the time saved in the unlock time mapping
        if (block.timestamp < unlockTime[msg.sender]) {
            revert LockTimeStillActive();
        }

        //Update user's balance
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        //Send balance back to the  caller
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }
}
