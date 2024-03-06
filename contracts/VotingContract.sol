// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

/* Events */
// Event to record when an election is created
event ElectionCreated(
    uint indexed electionId,
    string[] candidates,
    uint electionEndTime
);

// Event to record when an election is closed
event ElectionClosed(
    uint indexed electionId
);

/**
 * @title VotingContract
 * @dev Oversees the entire voting process, interacts with BallotContract to store votes.
 * Implements the logic for tallying votes based on RCV.
 */
contract VotingContract {
    /* State Variables */
    address private owner;

    // Counter to keep track of the number of elections
    uint private electionCount = 1;

    /* Constructor */
    // Set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    /* Enums */
    // Enum to track the status of an election
    enum ElectionStatus {
        notCreated,
        open,
        closed
    }

    /* Structs */
    // Struct to store a list of candidates for an election
    struct Election {
        uint electionId;
        string[] candidates;
        uint electionStartTime;
        uint electionEndTime;
        ElectionStatus status;
    }

    /* Mappings */
    // Mapping of election index to the election
    mapping(uint => Election) private elections;

    /* Modifiers */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /* Functions */
    /**
     * @dev Function to add an election to the contract
     * @param _candidates The list of candidates for the election
     * @param _timeDays The number of days the election will be open
     */
    function addElection(string[] memory _candidates, uint _timeDays) public onlyOwner {
        // Require that the election has at least 2 candidates
        require(_candidates.length > 1, "There must be more than one candidate");
        // Maximum amount of candidates in 5
        require (_candidates.length <= 5, "An election can have a maximum of 5 candidates");

        // Store the start time of the election
        uint electionStartTime = block.timestamp;

        // Calculate the end time of the election
        uint electionEndTime = block.timestamp + (_timeDays * 1 days);

        // Add the election to the list of elections
        Election memory newElection = Election(electionCount, _candidates, electionStartTime, electionEndTime, ElectionStatus.open);

        // Record the election in the mapping
        elections[electionCount] = newElection;
        
        // Increment the election count
        electionCount += 1;

        // Emit an event to record the creation of the election
        emit ElectionCreated(newElection.electionId, newElection.candidates, newElection.electionEndTime);
    }

    /**
     * @dev Function to close an election
     * @param _electionId The ID of the election to close
     */
    function closeElection(uint _electionId) public onlyOwner {
        // Require that the election exists
        require(_electionId > 0 && _electionId < electionCount, "Election does not exist");
        // Require that the election is open
        require(elections[_electionId].status == ElectionStatus.open, "Election is already closed");

        // Get the election
        Election storage election = elections[_electionId];

        // Check if the current time is past the election end time
        if (block.timestamp > election.electionEndTime) {
            // If it is, set the election status to closed
            election.status = ElectionStatus.closed;
        }
    }  

    /* Getter Functions */
    // Function to get the owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }

    // function to get the election count
    function getElectionCount() public view returns (uint) {
        return electionCount;
    }

    // Function to get the details of an election
    function getElection(uint _electionId) public view returns (string[] memory, uint, uint, ElectionStatus) {
        return (elections[_electionId].candidates, elections[_electionId].electionStartTime , elections[_electionId].electionEndTime, elections[_electionId].status);
    }

    // Function to get the candidates of an election
    function getElectionCandidates(uint _electionId) public view returns (string[] memory) {
        return elections[_electionId].candidates;
    }

    // Function to get the status of an election
    function getElectionStatus(uint _electionId) public view returns (ElectionStatus) {
        return elections[_electionId].status;
    }

    // Function to get the start time of an election
    function getElectionStartTime(uint _electionId) public view returns (uint) {
        return elections[_electionId].electionStartTime;
    }

    // Function to get the end time of an election
    function getElectionEndTime(uint _electionId) public view returns (uint) {
        return elections[_electionId].electionEndTime;
    }
}



