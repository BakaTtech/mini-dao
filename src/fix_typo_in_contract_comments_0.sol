// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title MiniDAO Governance Contract
/// @author MiniDAO Team
/// @notice This contract manages decentralized governance for the MiniDAO protocol
/// @dev Implements basic voting and proposal mechanisms with token-based governance
contract MiniDAOGovernance {
    /// @notice Emitted when a new proposal is created
    /// @param proposalId Unique identifier for the proposal
    /// @param proposer Address that created the proposal
    /// @param description Brief description of the proposal
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        string description
    );

    /// @notice Emitted when a vote is cast on a proposal
    /// @param proposalId Unique identifier for the proposal
    /// @param voter Address casting the vote
    /// @param support Boolean indicating for or against the proposal
    event VoteCast(
        uint256 proposalId,
        address voter,
        bool support
    );

    /// @notice Emitted when a proposal is executed
    /// @param proposalId Unique identifier for the proposal
    event ProposalExecuted(uint256 proposalId);

    /// @notice Structure representing a governance proposal
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        bool canceled;
    }

    /// @notice Mapping of proposal IDs to proposal data
    mapping(uint256 => Proposal) public proposals;

    /// @notice Total number of proposals created
    uint256 public proposalCount;

    /// @notice Minimum voting threshold required for proposal execution
    uint256 public constant MIN_VOTING_THRESHOLD = 1000;

    /// @notice Voting delay in blocks before voting starts
    uint256 public constant VOTING_DELAY = 1;

    /// @notice Voting period in blocks
    uint256 public constant VOTING_PERIOD = 1000;

    /// @notice Token contract address for governance
    address public tokenAddress;

    /// @notice Initializes the governance contract with token address
    /// @param _tokenAddress Address of the governance token
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    /// @notice Creates a new governance proposal
    /// @param description Description of the proposal
    /// @return proposalId Unique identifier for the new proposal
    function createProposal(string memory description)
        public
        returns (uint256 proposalId)
    {
        proposalCount++;
        proposalId = proposalCount;

        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            description: description,
            voteStart: block.number + VOTING_DELAY,
            voteEnd: block.number + VOTING_DELAY + VOTING_PERIOD,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            canceled: false
        });

        emit ProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }

    /// @notice Casts a vote on a proposal
    /// @param proposalId Unique identifier for the proposal
    /// @param support Boolean indicating for or against the proposal
    function castVote(uint256 proposalId, bool support) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(block.number >= proposal.voteStart, "Voting has not started");
        require(block.number <= proposal.voteEnd, "Voting has ended");
        require(!proposal.executed, "Proposal already executed");

        if (support) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }

        emit VoteCast(proposalId, msg.sender, support);
    }

    /// @notice Executes a proposal if quorum is met
    /// @param proposalId Unique identifier for the proposal
    function executeProposal(uint256 proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.canceled, "Proposal canceled");
        require(block.number > proposal.voteEnd, "Voting period not ended");

        // Simple quorum check
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        require(totalVotes >= MIN_VOTING_THRESHOLD, "Insufficient votes");

        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
}
