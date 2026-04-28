// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicDAO {
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        bool executed;
        uint proposalEndTime;
        mapping(address => bool) votes;
    }
    
    mapping(uint => Proposal) public proposals;
    uint public proposalCount;
    uint public quorum;
    uint public votingPeriod;
    
    address public owner;
    
    constructor(uint _quorum, uint _votingPeriod) {
        owner = msg.sender;
        quorum = _quorum;
        votingPeriod = _votingPeriod;
    }
    
    function createProposal(string memory _description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            executed: false,
            proposalEndTime: block.timestamp + votingPeriod
        });
    }
    
    function vote(uint _proposalId) public {
        require(block.timestamp < proposals[_proposalId].proposalEndTime, "Voting period has ended");
        require(!proposals[_proposalId].votes[msg.sender], "Already voted");
        
        proposals[_proposalId].votes[msg.sender] = true;
        proposals[_proposalId].voteCount++;
    }
    
    function executeProposal(uint _proposalId) public {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(proposals[_proposalId].voteCount >= quorum, "Quorum not reached");
        require(block.timestamp >= proposals[_proposalId].proposalEndTime, "Voting period not ended");
        
        proposals[_proposalId].executed = true;
    }
}
