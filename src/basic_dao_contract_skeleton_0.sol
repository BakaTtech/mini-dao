// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    // Governance structures
    address public owner;
    mapping(address => bool) public isMember;
    uint256 public proposalCount;
    
    // Proposal structure
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        bool closed;
    }
    
    // Vote structure
    struct Vote {
        bool vote;
        bool hasVoted;
    }
    
    // State variables
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Vote)) public votes;
    
    // Events
    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 id);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyMembers() {
        require(isMember[msg.sender], "Only members can call this function");
        _;
    }
    
    // Constructor
    constructor() {
        owner = msg.sender;
        isMember[msg.sender] = true;
    }
    
    // Core functions
    function createProposal(string memory _description) public onlyMembers {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            executed: false,
            closed: false
        });
        emit ProposalCreated(proposalCount, _description);
    }
    
    function vote(uint256 _proposalId, bool _vote) public onlyMembers {
        require(!proposals[_proposalId].closed, "Proposal is closed");
        require(!votes[_proposalId][msg.sender].hasVoted, "Already voted");
        
        votes[_proposalId][msg.sender] = Vote({vote: _vote, hasVoted: true});
        proposals[_proposalId].voteCount += _vote ? 1 : 0;
        emit Voted(_proposalId, msg.sender, _vote);
    }
    
    function executeProposal(uint256 _proposalId) public onlyMembers {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(!proposals[_proposalId].closed, "Proposal is closed");
        require(proposals[_proposalId].voteCount > 0, "No votes");
        
        proposals[_proposalId].executed = true;
        proposals[_proposalId].closed = true;
        emit ProposalExecuted(_proposalId);
    }
    
    // Membership functions
    function addMember(address _member) public onlyOwner {
        isMember[_member] = true;
    }
    
    function removeMember(address _member) public onlyOwner {
        isMember[_member] = false;
    }
}
