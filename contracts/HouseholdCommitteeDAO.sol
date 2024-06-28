// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

/* 
1. Adding Proposal Struct: To store proposal details.
2. Membership Management: Functions to add and remove members.
3. Creating Proposals: A function to create new proposals.
4. Voting Mechanism: Functions for members to vote on proposals.
5. Execution of Proposals: Logic to execute proposals once they have enough votes.
 */

contract HouseholdCommitteeDAO is Ownable {
	uint256 private value;

	// Emitted when the stored value changes
	event ValueChanged(uint256 newValue);

	// Emitted when a new proposal is created
	event ProposalCreated(uint256 proposalId, string description);

	// Emitted when a vote is cast
	event VoteCast(address voter, uint256 proposalId);

	// Emitted when a proposal is executed
	event ProposalExecuted(uint256 proposalId);

	// Struct proposal
	struct Proposal {
		uint id;
		string description;
		uint voteCount;
		bool executed;
	}

	// Mapping to store proposals
	mapping(uint => Proposal) public proposals;
	uint public proposalCount;

	// Mapping to store member
	mapping(address => bool) public members;
	uint public memberCount;

	// Modifier to check if the sender is a member
	modifier onlyMember() {
		require(members[msg.sender], "Not a member");
		_;
	}

	// Constructor to initialize the contract owner as a member
	constructor(address initialOwner) Ownable(initialOwner) {
		members[initialOwner] = true;
		memberCount = 1;
	}
	
	// Function to add a new member
	function addMember(address member) public onlyOwner {
		require(!members[member], "Already a member");
		members[member] = true;
		memberCount++;
	}

	// Function to remove a member
	function removeMember(address member) public onlyOwner {
		require(members[member], "Not a member");
		members[member] = false;
		memberCount--;
	}

	// Function to create a new proposal
	function createProposal(string memory description) public onlyOwner {
		proposalCount++;
		proposals[proposalCount] = Proposal(proposalCount, description, 0, false);
		emit ProposalCreated(proposalCount, description);
	}

	// Function to vote on a proposal
	function vote(uint proposalId) public onlyMember {
		Proposal storage proposal = proposals[proposalId];
		require(!proposal.executed, "Proposal already executed");
		proposal.voteCount++; 
		emit VoteCast(msg.sender, proposalId);
	}

	// Function to execute a proposal if it has enough votes
	function executeProposal(uint proposalId) public onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        uint requiredVotes = memberCount / 2; // Calculate majority
        if (memberCount % 2 != 0) {
            requiredVotes += 1; // Round up if necessary
        }
        require(proposal.voteCount > requiredVotes, "Not enough votes"); // Ensure more than half
        proposal.executed = true;
        // Add logic for executing the proposal (e.g., transferring funds)
        emit ProposalExecuted(proposalId);
	}


}