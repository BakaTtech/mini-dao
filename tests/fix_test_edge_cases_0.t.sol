// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MiniDAO.sol";

contract FixTestEdgeCases0 is Test {
    MiniDAO dao;
    address owner = address(0x1);
    address voter1 = address(0x2);
    address voter2 = address(0x3);

    function setUp() public {
        dao = new MiniDAO(owner);
        vm.prank(owner);
        dao.addMember(voter1);
        vm.prank(owner);
        dao.addMember(voter2);
    }

    function testProposalCannotBeVotedOnAfterDeadline() public {
        vm.warp(1000);
        uint256 proposalId = dao.createProposal("Test proposal", address(0x4), 1 ether);
        vm.warp(2000);
        vm.expectRevert(abi.encodeWithSelector(MiniDAO.ProposalExpired.selector));
        dao.vote(proposalId, true);
    }

    function testProposalCannotBeExecutedBeforeDeadline() public {
        vm.warp(1000);
        uint256 proposalId = dao.createProposal("Test proposal", address(0x4), 1 ether);
        vm.warp(1500);
        vm.expectRevert(abi.encodeWithSelector(MiniDAO.ProposalNotReady.selector));
        dao.executeProposal(proposalId);
    }

    function testCannotVoteTwice() public {
        uint256 proposalId = dao.createProposal("Test proposal", address(0x4), 1 ether);
        dao.vote(proposalId, true);
        vm.expectRevert(abi.encodeWithSelector(MiniDAO.AlreadyVoted.selector));
        dao.vote(proposalId, false);
    }

    function testProposalCannotBeCreatedWithZeroValue() public {
        vm.expectRevert(abi.encodeWithSelector(MiniDAO.InvalidProposal.selector));
        dao.createProposal("Test proposal", address(0x4), 0);
    }
}
