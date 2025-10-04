// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DemocraticCitadel {
        //----------structs---------
   struct Participant {
        uint ParticipantId;
        bool registered;
    }

    struct Proposal {
        uint proposalId;
        string description;
        address proposer;
        uint affirmativeVotes;
        uint dissentingVotes;
        bool passed;
        uint totalVotes;
        uint startTime;
        uint endTime;
        mapping(address => bool) hasVoted;
    }
    // --- Participant Management ---
    uint public participantCounter;

    function enrollParticipant() public {
        require(!participants[msg.sender].registered, "Already registered");
        participants[msg.sender].registered = true;
        participants[msg.sender].ParticipantId = participantCounter;
        participantCounter++;   
    }
    
    //--------mappings and variables
    
    uint public proposalCounter;
    mapping(address => Participant) public participants;
    mapping(uint => Proposal) public proposals;
    
    // To easily list all proposals
    uint[] public proposalIds;
    //uint256 public durationSeconds = 60 seconds;
    
      // Modify submitProposal to add time
    function submitProposal(string memory description, uint durationSeconds) public returns (uint) {
        require(participants[msg.sender].registered, "Not registered");
        proposalCounter++;
        Proposal storage p = proposals[proposalCounter];
        p.proposalId = proposalCounter;
        p.description = description;
        p.proposer = msg.sender;
        p.startTime = block.timestamp;
        p.endTime = block.timestamp + durationSeconds;
        proposalIds.push(proposalCounter);
        return proposalCounter;
    }

    // --- Voting Mechanism ---

    function castVote(uint _proposalId, bool support) public {
        require(participants[msg.sender].registered, "Not registered");
        Proposal storage p = proposals[_proposalId];
        require(p.proposalId == _proposalId, "Invalid proposal");
        require(!p.hasVoted[msg.sender], "Already voted");

        p.hasVoted[msg.sender] = true;
        p.totalVotes++;
        if (support) {
            p.affirmativeVotes++;
        } else {
            p.dissentingVotes++;
        }

        // Update proposal approval status after every vote
        if (p.affirmativeVotes * 100 /(p.affirmativeVotes+p.dissentingVotes) > 51) { // >51% threshold
            p.passed = true;
        }
    }

    // --- Result Access ---

   function retrieveProposalResults(uint _proposalId) public view returns (
    string memory,string memory,string memory,string memory, string memory, uint, string memory,uint, string memory,bool) {
    Proposal storage p = proposals[_proposalId];
    string memory resultMessage;

    if(block.timestamp >=p.endTime){
        if (p.passed) {
            resultMessage = "-------Will of The CITADEL------------\n the proposal has garnered the most support is ready to be implemented as a law.";
        } else {
            resultMessage = "-------Will of The CITADEL------------\n the proposal has not  garnered the support of majority and will NOT be implemented as a law.";
        }
    } else {
        resultMessage = "Voting time hasn't ended yet.";
    }
    return (
        "results:",resultMessage,
        "Proposal:",
        p.description,
        "Affirmative Votes:",
        p.affirmativeVotes,
        "Dissenting Votes:",
        p.dissentingVotes,
        "Passed:",
        p.passed
    );
}


    // --- Utilities ---
    function listProposals() public view returns (uint[] memory) {
        return proposalIds;
    }
}
