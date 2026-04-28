// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    uint256 public proposalCount;
    uint256 public quorum;
    uint256 public votingPeriod;
    
    address public owner;
    
    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 id, address voter, bool support);
    event ProposalExecuted(uint256 id);

    constructor(uint256 _quorum, uint256 _votingPeriod) {
        owner = msg.sender;
        quorum = _quorum;
        votingPeriod = _votingPeriod;
    }
    
    function addMember(address member) public {
        require(msg.sender == owner, "Only owner can add members");
        members[member] = true;
    }
    
    function createProposal(string memory description) public {
        require(members[msg.sender], "Only members can create proposals");
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: description,
            voteCount: 0,
            executed: false,
            deadline: block.timestamp + votingPeriod,
            yesVotes: 0,
            noVotes: 0
        });
        emit ProposalCreated(proposalCount, description);
    }
    
    function vote(uint256 proposalId, bool support) public {
        require(members[msg.sender], "Only members can vote");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(block.timestamp < proposals[proposalId].deadline, "Voting period ended");
        require(!proposals[proposalId].executed, "Proposal already executed");
        
        hasVoted[proposalId][msg.sender] = true;
        if (support) {
            proposals[proposalId].yesVotes++;
        } else {
            proposals[proposalId].noVotes++;
        }
        proposals[proposalId].voteCount++;
        emit Voted(proposalId, msg.sender, support);
    }
}
