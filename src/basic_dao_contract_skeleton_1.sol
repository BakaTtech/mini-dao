// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicDAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        bool canceled;
    }

    struct Vote {
        bool voted;
        bool support;
    }

    address public owner;
    uint256 public quorum;
    uint256 public votingPeriod;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => Vote)) public votes;
    uint256 public proposalCount;

    constructor(uint256 _quorum, uint256 _votingPeriod) {
        owner = msg.sender;
        quorum = _quorum;
        votingPeriod = _votingPeriod;
    }

    function createProposal(string memory description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: description,
            voteStart: block.timestamp,
            voteEnd: block.timestamp + votingPeriod,
            yesVotes: 0,
            noVotes: 0,
            executed: false,
            canceled: false
        });
    }

    function vote(uint256 proposalId, bool support) public {
        require(block.timestamp < proposals[proposalId].voteEnd, "Voting period has ended");
        require(!votes[msg.sender][proposalId].voted, "Already voted");
        
        votes[msg.sender][proposalId] = Vote({voted: true, support: support});
        
        if (support) {
            proposals[proposalId].yesVotes++;
        } else {
            proposals[proposalId].noVotes++;
        }
    }
}
