// SPDX-Identifier: MIT

pragma solidity 0.8.22;

/* Events */
// Event to record when an election is created
event ElectionCreated(
    uint indexed electionId,
    string[] candidates,
    uint electionEndTime
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
        open,
        closed
    }

    /* Structs */
    // Struct to store a list of candidates for an election
    struct Election {
        uint electionId;
        string[] candidates;
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
    // Function to add a new election which takes a list of candidates and the chosen length of time for the election as input
    function addElection(string[] memory _candidates, uint _timeDays) public onlyOwner {
        // Calculate the end time of the election
        uint electionEndTime = block.timestamp + (_timeDays * 1 days);

        // Add the election to the list of elections
        Election memory newElection = Election(electionCount, _candidates, electionEndTime, ElectionStatus.open);

        // Record the election in the mapping
        elections[electionCount] = newElection;
        
        // Increment the election count
        electionCount += 1;

        // Emit an event to record the creation of the election
        emit ElectionCreated(newElection.electionId, newElection.candidates, newElection.electionEndTime);
    }

    // Function to close an election when the electionEndTime has passed

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
    function getElection(uint _electionId) public view returns (string[] memory, uint, ElectionStatus) {
        return (elections[_electionId].candidates, elections[_electionId].electionEndTime, elections[_electionId].status);
    }

    // Function to get the candidates of an election
    function getElectionCandidates(uint _electionId) public view returns (string[] memory) {
        return elections[_electionId].candidates;
    }

    // Function to get the status of an election
    function getElectionStatus(uint _electionId) public view returns (ElectionStatus) {
        return elections[_electionId].status;
    }

    // Function to get the end time of an election
    function getElectionEndTime(uint _electionId) public view returns (uint) {
        return elections[_electionId].electionEndTime;
    }
}
