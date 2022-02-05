// SPDX-License-Identifier: UNLICENCED

pragma solidity >=0.5.0 < 0.9.0;


/*
* Smart Contract for Crowd Funding
* Manager can define
    Target amount
    deadline to reach target(in terms of seconds per day*number of days)
    minimum contribution amount

 Contract will take contribution 
    only if 
        deadline not reached
        target not achived
        contribution amount should be equal to or greater then minimum contribution
    any number of time from same contributor

*  
*/
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public deadLine;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public noRequests;

    modifier onlyManager() {
        require(msg.sender == manager, "Only Manager Can Access");
        _;
    }

    constructor(uint _target, uint _deadLine, uint _minContribution) {
        target = _target;
        deadLine = _deadLine + block.timestamp;
        minContribution = _minContribution;
        manager = msg.sender;
        
    }

    function contribute() public payable {
        require(block.timestamp < deadLine, "Deadline reached");
        require(raisedAmount < target, "Target achived");
        require(msg.value >= minContribution, "Insufficient Amount");

        // increase no of contributors for every new contributor
        if(contributors[msg.sender]==0) {
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getContractBalance() public view returns(uint) {
        require(msg.sender == manager);
        return address(this).balance;
    }

    function refund() public {
        require(contributors[msg.sender]> 0);
        require(raisedAmount<target && block.timestamp > deadLine, "Currently Refund not allowed");
        address payable contributor = payable(msg.sender);
        contributor.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
        require(raisedAmount < contributors[msg.sender], "Refunds Completed");
        raisedAmount-=contributors[msg.sender];
    }

    function createRequest(string memory _desc, uint _value, address payable _recipient) public onlyManager {
        Request storage newRequest = requests[noRequests];
        noRequests++;
        newRequest.description = _desc;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0, "Only Contributors can vote");
        require(noRequests < _requestNo, "Request doesn't exist");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false, "Already voted!");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager {
        require(noRequests < _requestNo, "Request doesn't exist");
        require(raisedAmount >= target, "Insufficient Balance");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "The request already completed");
        require(thisRequest.noOfVoters > noOfContributors/2, "Minimum votes not reached");
        require(thisRequest.value <= raisedAmount, "Not enough amount raised");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
