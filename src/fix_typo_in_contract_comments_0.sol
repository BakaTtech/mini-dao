// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title MiniDAO Governance Contract
/// @author MiniDAO Team
/// @notice This contract manages decentralized governance for the MiniDAO protocol
/// @dev Implements basic voting and proposal mechanisms for token holders
contract MiniDAO {
    /// @dev Mapping of proposal IDs to proposal details
    mapping(uint256 => Proposal) public proposals;
    
    /// @dev Tracks total votes for each proposal
    mapping(uint256 => uint256) public proposalVotes;
    
    /// @dev Stores token balances for each address
    mapping(address => uint256) public balances;
    
    /// @dev Tracks which addresses have voted on which proposals
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    /// @dev Emitted when a new proposal is created
    event ProposalCreated(
        uint256 id,
        address proposer,
        string description
    );
    
    /// @dev Emitted when a vote is cast
    event VoteCast(
        uint256 proposalId,
        address voter,
        bool support
    );
    
    /// @dev Proposal structure holding all relevant data
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 voteCount;
        bool executed;
        uint256 deadline;
    }
    
    /// @dev Creates a new governance proposal
    /// @param _description Description of the proposal
    /// @return proposalId Unique identifier for the new proposal
    function createProposal(string memory _description) public returns (uint256) {
        uint256 proposalId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            description: _description,
            voteCount: 0,
            executed: false,
            deadline: block.timestamp + 7 days
        });
        
        emit ProposalCreated(proposalId, msg.sender, _description);
        return proposalId;
    }
    
    /// @dev Casts a vote for a specific proposal
    /// @param _proposalId ID of the proposal to vote on
    /// @param _support Whether the vote supports the proposal
    function vote(uint256 _proposalId, bool _support) public {
        require(!hasVoted[_proposalId][msg.sender], "Already voted");
        require(block.timestamp < proposals[_proposalId].deadline, "Proposal expired");
        
        hasVoted[_proposalId][msg.sender] = true;
        proposalVotes[_proposalId] += _support ? 1 : 0;
        
        emit VoteCast(_proposalId, msg.sender, _support);
    }
}
