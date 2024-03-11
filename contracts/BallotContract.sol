// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

/* Imports */
import "./IBallotContract.sol";

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
 * @title BallotContract
 * @dev Oversees the entire voting process, interacts with VotingContract to store votes.
 * Implements the logic for tallying votes based on RCV.
 */
contract BallotContract is IBallotContract {
    /* State Variables */
    address private owner;

    // Counter to keep track of the number of elections
    uint private electionCount = 1;

    // Array to store open elections
    uint[] public openElections;

    // Array to store closed elections
    uint[] public closedElections;

    // Election Status bool
    bool public electionOpen = false;

    /* Constructor */
    // Set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    /* Structs */
    // Struct to store a list of candidates for an election
    struct Election {
        uint electionId;
        string[] candidates;
        uint electionStartTime;
        uint electionEndTime;
        bool electionOpen;
    }

    // Struct to store a voter's ranked choices
    struct VoterChoices {
        uint8 firstChoice;
        uint8 secondChoice;
        uint8 thirdChoice;
        bool hasVoted;
    }

    /* Mappings */
    // Mapping of election index to the election
    mapping(uint => Election) private elections;

    // Mapping of voter address to their ranked choices
    mapping(uint=> mapping(address => VoterChoices)) public voterChoices;


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
        Election memory newElection = Election(electionCount, _candidates, electionStartTime, electionEndTime, true);

        // Record the election in the mapping
        elections[electionCount] = newElection;

        // Add the election to the list of open elections
        openElections.push(electionCount);
        
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
        require(elections[_electionId].electionOpen == true, "Election is already closed");

        // Get the election
        Election storage election = elections[_electionId];

        // Check if the current time is past the election end time
        if (block.timestamp > election.electionEndTime) {
            // If it is, set the election status to closed
            election.electionOpen = false;

            // Emit an event to record the closing of the election
            emit ElectionClosed(_electionId);

            // Remove the election from the list of open elections
            for (uint i = 0; i < openElections.length; i++) {
                if (openElections[i] == _electionId) {
                    openElections[i] = openElections[openElections.length - 1];
                    openElections.pop();
                    break;
                }
            }

            // Add the election to the list of closed elections
            closedElections.push(_electionId);
        } else {
            // If it is not, revert the transaction
            revert("Election is still open");}
    }

    /**
     * @dev Function to add votes to the contract
     * @param _electionId The ID of the election to add votes to
     * @param _votes The list of votes to add
     */
    function addVotes(uint8[] memory _votes, uint _electionId) external{
        // require that the election is open
        require (elections[_electionId].electionOpen == true, "Election is not open");
        // Require the right amount of votes
        require (_votes.length == elections[_electionId].candidates.length, "The amount of votes does not match the amount of candidates");

        uint8[] memory votes = _votes;

        // Create a new voter choice
        VoterChoices memory voterChoice = VoterChoices(
            votes[0],
            votes[1],
            votes[2],
            true
        );

        // Record the voter's choices
        // 
        //map the voter's address to their choices
        voterChoices[_electionId][msg.sender] = voterChoice;
        
    }

    /* Getter Functions */
    // Function to get the owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }

    // function to get the election count
    function getElectionCount() public view returns (uint) {
        return electionCount - 1;
    }

    // Function to get the open elections
    function getOpenElections() public view returns (uint[] memory) {
        return openElections;
    }

    // Function to get the closed elections
    function getClosedElections() public view returns (uint[] memory) {
        return closedElections;
    }

    // Function to get the details of an election
    function getElection(uint _electionId) public view returns (string[] memory, uint, uint, bool) {
        return (elections[_electionId].candidates, elections[_electionId].electionStartTime , elections[_electionId].electionEndTime, elections[_electionId].electionOpen);
    }

    // Function to get the candidates of an election
    function getElectionCandidates(uint _electionId) public view returns (string[] memory) {
        return elections[_electionId].candidates;
    }

    // Function to get the status of an election
    function getElectionStatus(uint _electionId) external view returns (bool) {
        return elections[_electionId].electionOpen;
    }

    // Function to get the start time of an election
    function getElectionStartTime(uint _electionId) public view returns (uint) {
        return elections[_electionId].electionStartTime;
    }

    // Function to get the end time of an election
    function getElectionEndTime(uint _electionId) public view returns (uint) {
        return elections[_electionId].electionEndTime;
    }

    // Function to get a voter's vote status
    function getVoterStatus(address _voter, uint _electionId) public view returns (bool) {
        return voterChoices[_electionId][_voter].hasVoted;
    }

    // Function to get a voter's ranked choices
    function getVoterChoices(
        address _voter, uint _electionId
    ) public view returns (uint8, uint8, uint8) {
        return (
            voterChoices[_electionId][_voter].firstChoice,
            voterChoices[_electionId][_voter].secondChoice,
            voterChoices[_electionId][_voter].thirdChoice
        );
    }
}



