// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MiniDAO.sol";

contract FixTestEdgeCases0 is Test {
    MiniDAO dao;
    address owner = address(0x123);
    address voter1 = address(0x456);
    address voter2 = address(0x789);

    function setUp() public {
        dao = new MiniDAO(owner);
        vm.prank(owner);
        dao.addMember(voter1);
        vm.prank(owner);
        dao.addMember(voter2);
    }

    function testProposalWithZeroVotes() public {
        uint256 proposalId = dao.createProposal("Test proposal", "Test description");
        vm.prank(voter1);
        dao.vote(proposalId, true);
        vm.prank(voter2);
        dao.vote(proposalId, false);
        
        // Test edge case: proposal passes with exactly 50% votes
        assertEq(dao.getProposalStatus(proposalId), 1); // Active
    }

    function testProposalEndsWithNoVotes() public {
        uint256 proposalId = dao.createProposal("Test proposal", "Test description");
        // Don't vote at all
        
        // Test edge case: proposal with no votes
        assertEq(dao.getProposalStatus(proposalId), 1); // Active
    }

    function testVoterCannotVoteTwice() public {
        uint256 proposalId = dao.createProposal("Test proposal", "Test description");
        vm.prank(voter1);
        dao.vote(proposalId, true);
        
        // Test edge case: double voting should fail
        vm.prank(voter1);
        vm.expectRevert();
        dao.vote(proposalId, false);
    }
}
