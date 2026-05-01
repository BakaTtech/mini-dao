// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MiniDAO {
    address public owner;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    
    struct Proposal {
        string description;
        uint256 targetValue;
        bool executed;
        bool proposalPassed;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function addProposal(string memory _description, uint256 _targetValue) public onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: _description,
            targetValue: _targetValue,
            executed: false,
            proposalPassed: false
        });
    }
    
    function executeProposal(uint256 _proposalId) public onlyOwner {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID");
        require(!proposals[_proposalId].executed, "Proposal already executed");
        require(proposals[_proposalId].proposalPassed, "Proposal not passed");
        
        proposals[_proposalId].executed = true;
        
        // Execute the proposal logic here
        // For this example, we'll just mark it as executed
    }
}
