// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceContract is Ownable {
    IERC20 public lpToken;
    uint256 public totalVotes;

    struct Voter {
        uint256 votes;
        bool hasVoted;
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => uint256) public proposalVotes;
    uint256 public proposalCounter;
    uint256 public minVotesRequired;

    constructor(address _lpToken, uint256 _minVotesRequired) {
        lpToken = IERC20(_lpToken);
        minVotesRequired = _minVotesRequired;
    }

    function createProposal(uint256 proposalId) external onlyOwner {
        require(proposalVotes[proposalId] == 0, "Proposal already exists");
        proposalVotes[proposalId] = 0;
    }

    function vote(uint256 proposalId, uint256 votes) external {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(votes > 0, "Votes must be greater than 0");
        require(lpToken.transferFrom(msg.sender, address(this), votes), "Transfer of voting tokens failed");

        voters[msg.sender].votes = votes;
        voters[msg.sender].hasVoted = true;
        proposalVotes[proposalId] += votes;
        totalVotes += votes;
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalVotes[proposalId] >= minVotesRequired, "Proposal doesn't have enough votes");


        proposalVotes[proposalId] = 0;
        proposalCounter++;
        totalVotes = 0;
    }

    function cancelVote(uint256 proposalId) external {
        require(voters[msg.sender].hasVoted, "You haven't voted yet");

        uint256 votes = voters[msg.sender].votes;
        proposalVotes[proposalId] -= votes;
        totalVotes -= votes;

        voters[msg.sender].votes = 0;
        voters[msg.sender].hasVoted = false;
        require(lpToken.transfer(msg.sender, votes), "Transfer of voting tokens failed");
    }
}
