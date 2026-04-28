// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        bool executed;
        uint expirationTime;
    }
    
    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public hasVoted;
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
            expirationTime: block.timestamp + votingPeriod
        });
    }
    
    function vote(uint _proposalId) public {
        require(!hasVoted[msg.sender][_proposalId], "Already voted");
        require(block.timestamp < proposals[_proposalId].expirationTime, "Proposal expired");
        hasVoted[msg.sender][_proposalId] = true;
        proposals[_proposalId].voteCount++;
    }
    
    function executeProposal(uint _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount >= quorum, "Not enough votes");
        require(block.timestamp >= proposal.expirationTime, "Voting period not ended");
        proposal.executed = true;
    }
}
