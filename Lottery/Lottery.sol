// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <= 0.9.0;

/**
* Decentralised Lottery Application
* Parties
    Manager (owner)
    Participants
* Algorithm
    Participants must have a wallet
    A participants can transfer ehter once or more, can send only 2 ether once
    As the particiants will transfer ehther its address will be registered
    Manager will have full control over the lottery
    The contract will be reset once a round completed
*/
contract Lottery{
    address public manager;
    address payable[] public participants;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        // to participate need to send exact 2 ethers
        require(msg.value == 2 ether);
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        // only manager can view balance
        require(msg.sender == manager);
        return address(this).balance;
    }
}