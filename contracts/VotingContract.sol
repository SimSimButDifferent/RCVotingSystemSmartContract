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

    /* Getter Functions */
    // Function to get the owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }
}
