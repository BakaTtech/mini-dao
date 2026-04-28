// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    address public owner;
    uint256 public proposalThreshold;
    uint256 public quorum;
    uint256 public votingPeriod;
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        bool canceled;
        address creator;
        uint256 createdAt;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(address => bool)) public voted;
    
    event ProposalCreated(uint256 id, address creator);
    event Voted(uint256 id, address voter);
    event ProposalExecuted(uint256 id);
    
    constructor(uint256 _proposalThreshold, uint256 _quorum, uint256 _votingPeriod) {
        owner = msg.sender;
        proposalThreshold = _proposalThreshold;
        quorum = _quorum;
        votingPeriod = _votingPeriod;
    }
    
    function createProposal(string memory _description) public {
        require(balances[msg.sender] >= proposalThreshold, "Insufficient balance to create proposal");
        uint256 id = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        proposals[id] = Proposal({
            id: id,
            description: _description,
            voteCount: 0,
            executed: false,
            canceled: false,
            creator: msg.sender,
            createdAt: block.timestamp
        });
        emit ProposalCreated(id, msg.sender);
    }
    
    function vote(uint256 _proposalId) public {
        require(!voted[_proposalId][msg.sender], "Already voted");
        require(!proposals[_proposalId].canceled, "Proposal canceled");
        require(block.timestamp < proposals[_proposalId].createdAt + votingPeriod, "Voting period ended");
        
        voted[_proposalId][msg.sender] = true;
        proposals[_proposalId].voteCount += balances[msg.sender];
        emit Voted(_proposalId, msg.sender);
    }
    
    function executeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount >= quorum, "Not enough votes");
        require(block.timestamp >= proposal.createdAt + votingPeriod, "Voting period not ended");
        
        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }
}
