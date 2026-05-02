// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title MiniDAO Governance Contract
/// @author MiniDAO Team
/// @notice This contract implements a minimal decentralized autonomous organization
/// @dev This contract manages voting, proposal creation, and token-based governance
contract MiniDAO {
    /// @notice Address of the DAO treasury
    address public treasury;
    
    /// @notice Total supply of governance tokens
    uint256 public totalSupply;
    
    /// @notice Mapping of token balances for each address
    mapping(address => uint256) public balanceOf;
    
    /// @notice Mapping of proposal IDs to proposal details
    mapping(uint256 => Proposal) public proposals;
    
    /// @notice Mapping of voter addresses to proposal votes
    mapping(address => mapping(uint256 => bool)) public votes;
    
    /// @notice Number of proposals created
    uint256 public proposalCount;
    
    /// @notice Minimum voting threshold for proposal approval
    uint256 public quorum;
    
    /// @notice Duration of voting period in seconds
    uint256 public votingPeriod;
    
    /// @notice Structure representing a governance proposal
    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        uint256 deadline;
    }
    
    /// @notice Emitted when a new proposal is created
    event ProposalCreated(uint256 id, string description);
    
    /// @notice Emitted when a vote is cast
    event Voted(address voter, uint256 proposalId, bool support);
    
    /// @notice Emitted when a proposal is executed
    event ProposalExecuted(uint256 id);
}
