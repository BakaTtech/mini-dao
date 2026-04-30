// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MiniDAO.sol";

contract MiniDAOTest is Test {
    MiniDAO dao;
    address proposer = makeAddr("proposer");
    address voter1 = makeAddr("voter1");
    address voter2 = makeAddr("voter2");

    function setUp() public {
        dao = new MiniDAO();
        vm.prank(proposer);
        dao.createProposal("Test proposal", "Test description");
    }

    function testVotingOnNonExistentProposalReverts() public {
        vm.expectRevert(abi.encodeWithSelector(MiniDAO.ProposalDoesNotExist.selector, 999));
        dao.vote(999, true);
    }

    function testVotingTwiceReverts() public {
        vm.prank(voter1);
        dao.vote(0, true);
        
        vm.expectRevert(abi.encodeWithSelector(MiniDAO.VoterAlreadyVoted.selector, voter1));
        vm.prank(voter1);
        dao.vote(0, false);
    }

    function testProposalStateTransitions() public {
        // Check initial state
        MiniDAO.Proposal memory proposal = dao.getProposal(0);
        assertEq(uint8(proposal.state), uint8(MiniDAO.ProposalState.Pending));
        
        // Vote to pass
        vm.prank(voter1);
        dao.vote(0, true);
        
        proposal = dao.getProposal(0);
        assertEq(uint8(proposal.state), uint8(MiniDAO.ProposalState.Active));
        
        // Vote to fail
        vm.prank(voter2);
        dao.vote(0, false);
        
        proposal = dao.getProposal(0);
        assertEq(uint8(proposal.state), uint8(MiniDAO.ProposalState.Active));
        
        // Final vote to pass
        vm.prank(voter1);
        dao.vote(0, true);
        
        proposal = dao.getProposal(0);
        assertEq(uint8(proposal.state), uint8(MiniDAO.ProposalState.Passed));
    }
}
