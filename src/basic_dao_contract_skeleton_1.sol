// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        bool canceled;
    }
    
    struct Vote {
        bool voted;
        uint8 choice; // 0: against, 1: for
    }
    
    mapping(address => uint256) public balances;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => Vote)) public votes;
    
    uint256 public proposalCount;
    uint256 public quorum;
    uint256 public votingPeriod;
    
    address public owner;
    
    event ProposalCreated(uint256 id, string description);
    event Voted(address voter, uint256 proposalId, uint8 choice);
    event ProposalExecuted(uint256 id);
    
    constructor(uint256 _quorum, uint256 _votingPeriod) {
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
            canceled: false
        });
        emit ProposalCreated(proposalCount, _description);
    }
    
    function vote(uint256 _proposalId, uint8 _choice) public {
        require(_choice <= 1, "Invalid choice");
        require(!votes[msg.sender][_proposalId].voted, "Already voted");
        
        votes[msg.sender][_proposalId] = Vote({
            voted: true,
            choice: _choice
        });
        
        proposals[_proposalId].voteCount += 1;
        emit Voted(msg.sender, _proposalId, _choice);
    }
    
    function executeProposal(uint256 _proposalId) public {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(proposals[_proposalId].voteCount >= quorum, "Quorum not reached");
        
        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }
}
