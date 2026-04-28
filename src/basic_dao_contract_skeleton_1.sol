// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    address public owner;
    uint256 public proposalCount;
    uint256 public quorum;
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        bool cancelled;
    }
    
    struct Vote {
        bool support;
        uint256 weight;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => Vote)) public votes;
    mapping(address => uint256) public tokenBalances;
    
    event ProposalCreated(uint256 id, string description);
    event Voted(address voter, uint256 proposalId, bool support);
    event ProposalExecuted(uint256 id);
    
    constructor(uint256 _quorum) {
        owner = msg.sender;
        quorum = _quorum;
    }
    
    function createProposal(string memory _description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            executed: false,
            cancelled: false
        });
        emit ProposalCreated(proposalCount, _description);
    }
    
    function vote(uint256 _proposalId, bool _support) public {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(!proposals[_proposalId].cancelled, "Proposal cancelled");
        require(tokenBalances[msg.sender] > 0, "No voting power");
        
        votes[msg.sender][_proposalId] = Vote({
            support: _support,
            weight: tokenBalances[msg.sender]
        });
        
        if (_support) {
            proposals[_proposalId].voteCount += tokenBalances[msg.sender];
        }
        
        emit Voted(msg.sender, _proposalId, _support);
    }
    
    function executeProposal(uint256 _proposalId) public {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(proposals[_proposalId].voteCount >= quorum, "Not enough votes");
        
        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }
    
    function depositTokens(uint256 _amount) public {
        tokenBalances[msg.sender] += _amount;
    }
}
