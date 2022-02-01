// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <= 0.9.0;

/**
* Decentralised Lottery Application
* Parties
    Manager (owner)
    Participants
* Algorithm
    Participants must have a wallet
    A participants can transfer ehter only once, can send only 2 ether once
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
        // include logic for make sure that a user can participate only once
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        // only manager can view balance
        require(msg.sender == manager);
        return address(this).balance;
    }
    
    // generate random number
    function random() internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function selectWinner() internal view returns(address) {
        // only manager can select winner
    require(msg.sender == manager);
    // select winner only if number of participants more then 4
    require(participants.length >= 3);
    uint randomNumber = random();
    address payable winner;
    uint index = randomNumber % participants.length;
    winner = participants[index];
    return winner;

    }

    function rewardWinner() public {
        require(msg.sender == manager);
        address payable winner  = payable(selectWinner());
        winner.transfer(getBalance());
        participants = new address payable[](0);
    }
}