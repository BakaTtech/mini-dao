// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniDAO {
    address public owner;
    uint256 public proposalCount;
    uint256 public quorum;
    
    struct Proposal {
        string description;
        uint256 targetAmount;
        address recipient;
        bool executed;
        mapping(address => bool) votes;
        uint256 voteCount;
    }
    
    mapping(uint256 => Proposal) public proposals;
    address[] public voters;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor(uint256 _quorum) {
        owner = msg.sender;
        quorum = _quorum;
    }
    
    function addVoter(address voter) external onlyOwner {
        voters.push(voter);
    }
    
    function createProposal(
        string memory description,
        uint256 targetAmount,
        address recipient
    ) external onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: description,
            targetAmount: targetAmount,
            recipient: recipient,
            executed: false,
            voteCount: 0
        });
    }
    
    function vote(uint256 proposalId) external {
        require(!proposals[proposalId].executed, "Proposal already executed");
        require(proposals[proposalId].votes[msg.sender] == false, "Already voted");
        
        proposals[proposalId].votes[msg.sender] = true;
        proposals[proposalId].voteCount++;
    }
    
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount >= quorum, "Not enough votes");
        
        proposal.executed = true;
        payable(proposal.recipient).transfer(proposal.targetAmount);
    }
}
