// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        bool isActive;
    }

    struct Vote {
        bool hasVoted;
        bool vote;
    }

    address public owner;
    uint256 public quorum;
    uint256 public votingPeriod;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => Vote)) public votes;
    uint256 public proposalCount;

    event ProposalCreated(uint256 id, string description);
    event Voted(address voter, uint256 proposalId, bool vote);
    event ProposalExecuted(uint256 id);

    constructor(uint256 _quorum, uint256 _votingPeriod) {
        owner = msg.sender;
        quorum = _quorum;
        votingPeriod = _votingPeriod;
        proposalCount = 0;
    }

    function createProposal(string memory _description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteStart: block.timestamp,
            voteEnd: block.timestamp + votingPeriod,
            yesVotes: 0,
            noVotes: 0,
            executed: false,
            isActive: true
        });
        emit ProposalCreated(proposalCount, _description);
    }

    function vote(uint256 _proposalId, bool _vote) public {
        require(proposals[_proposalId].isActive, "Proposal is not active");
        require(block.timestamp <= proposals[_proposalId].voteEnd, "Voting period has ended");
        require(!votes[msg.sender][_proposalId].hasVoted, "You have already voted");

        votes[msg.sender][_proposalId] = Vote({
            hasVoted: true,
            vote: _vote
        });

        if (_vote) {
            proposals[_proposalId].yesVotes++;
        } else {
            proposals[_proposalId].noVotes++;
        }

        emit Voted(msg.sender, _proposalId, _vote);
    }

    function executeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.isActive, "Proposal is not active");
        require(block.timestamp > proposal.voteEnd, "Voting period has not ended");
        require(proposal.yesVotes + proposal.noVotes >= quorum, "Quorum not reached");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        proposal.isActive = false;
        emit ProposalExecuted(_proposalId);
    }
}
