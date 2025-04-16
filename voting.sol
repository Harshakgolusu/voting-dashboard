// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address public admin;
    bool public electionStarted;
    bool public electionEnded;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
    }

    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;

    uint public candidatesCount;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier electionActive() {
        require(electionStarted && !electionEnded, "Election is not active");
        _;
    }

    // Add a candidate (admin only)
    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    // Register a voter
    function registerVoter(address _voter) public onlyAdmin {
        voters[_voter].isRegistered = true;
    }

    // Start the election
    function startElection() public onlyAdmin {
        require(!electionStarted, "Election already started");
        electionStarted = true;
    }

    // End the election
    function endElection() public onlyAdmin {
        require(electionStarted, "Election not started yet");
        electionEnded = true;
    }

    // Vote for a candidate
    function vote(uint _candidateId) public electionActive {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You are not registered to vote");
        require(!sender.hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");

        sender.hasVoted = true;
        candidates[_candidateId].voteCount++;
    }

    // View vote count (publicly accessible)
    function getVotes(uint _candidateId) public view returns (uint) {
        return candidates[_candidateId].voteCount;
    }

    // View candidate details
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }
}
