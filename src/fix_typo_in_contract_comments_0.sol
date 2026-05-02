// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title MiniDAO Governance Contract
/// @author MiniDAO Team
/// @notice This contract implements a minimal decentralized autonomous organization
/// @dev This contract manages voting rights, proposal creation, and governance decisions
contract MiniDAO {
    /// @notice Owner of the contract
    address public owner;
    
    /// @notice Total supply of governance tokens
    uint256 public totalSupply;
    
    /// @notice Mapping of token holders to their balances
    mapping(address => uint256) public balances;
    
    /// @notice Mapping of proposal IDs to proposal details
    mapping(uint256 => Proposal) public proposals;
    
    /// @notice Number of proposals created
    uint256 public proposalCount;
    
    /// @notice Voting period in seconds
    uint256 public votingPeriod;
    
    /// @notice Minimum quorum required for proposal execution
    uint256 public minimumQuorum;
    
    /// @notice Structure representing a governance proposal
    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        uint256 creationTime;
        uint256 endTime;
    }
    
    /// @notice Emitted when a new proposal is created
    event ProposalCreated(uint256 proposalId, string description);
    
    /// @notice Emitted when a vote is cast
    event VoteCast(address voter, uint256 proposalId, bool support);
    
    /// @notice Emitted when a proposal is executed
    event ProposalExecuted(uint256 proposalId);
    
    /// @dev Constructor initializes contract parameters
    constructor(uint256 _votingPeriod, uint256 _minimumQuorum) {
        owner = msg.sender;
        votingPeriod = _votingPeriod;
        minimumQuorum = _minimumQuorum;
        totalSupply = 1000000 * 10**18; // 1 million tokens
        balances[msg.sender] = totalSupply;
    }
    
    /// @notice Creates a new governance proposal
    /// @param _description Description of the proposal
    /// @return proposalId ID of the newly created proposal
    function createProposal(string memory _description) public returns (uint256) {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0,
            executed: false,
            creationTime: block.timestamp,
            endTime: block.timestamp + votingPeriod
        });
        emit ProposalCreated(proposalCount, _description);
        return proposalCount;
    }
    
    /// @notice Casts a vote on a proposal
    /// @param _proposalId ID of the proposal to vote on
    /// @param _support Whether the vote supports the proposal
    function vote(uint256 _proposalId, bool _support) public {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID");
        require(balances[msg.sender] > 0, "No voting power");
        require(block.timestamp < proposals[_proposalId].endTime, "Voting period ended");
        require(!proposals[_proposalId].executed, "Proposal already executed");
        
        proposals[_proposalId].voteCount += balances[msg.sender];
        emit VoteCast(msg.sender, _proposalId, _support);
    }
    
    /// @notice Executes a proposal if quorum is met
    /// @param _proposalId ID of the proposal to execute
    function executeProposal(uint256 _proposalId) public {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID");
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(block.timestamp >= proposals[_proposalId].endTime, "Voting period not ended");
        require(proposals[_proposalId].voteCount >= minimumQuorum, "Quorum not met");
        
        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }
}
