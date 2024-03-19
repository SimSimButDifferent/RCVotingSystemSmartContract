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
    bool private electionOpen = false;

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

    // Struct to store the vote count for each candidate
    struct CandidatesVoteCount {
        uint firstChoiceVotes;
        uint secondChoiceVotes;
        uint thirdChoiceVotes;
    }

    /* Mappings */
    // Mapping of election index to the election
    mapping(uint => Election) private elections;

    // Mapping of voter address to their ranked choices
    mapping(uint=> mapping(address => VoterChoices)) public voterChoices;

    // Mapping candidates to their vote count
    mapping(uint=> mapping(string => CandidatesVoteCount)) public candidatesVoteCount;


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

        // Create a new CandidatesVoteCount struct for each candidate
        CandidatesVoteCount memory newCandidate;

        // Add candidates to the candidatesVoteCount mapping
        for (uint i = 0; i < _candidates.length; i++) {
            newCandidate = CandidatesVoteCount(0, 0, 0);
            for (uint j = 0; j < _candidates.length; j++) {
                candidatesVoteCount[electionCount][_candidates[i]] = CandidatesVoteCount(0, 0, 0);
            }
        }

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



    // Function to update voter choices
    function updateVoterChoices(uint8 _firstChoice, uint8 _secondChoice, uint8 _thirdChoice, uint _electionId, address _voter) external {
        // Update the voter's choices
        voterChoices[_electionId][_voter].firstChoice = _firstChoice;
        voterChoices[_electionId][_voter].secondChoice = _secondChoice;
        voterChoices[_electionId][_voter].thirdChoice = _thirdChoice;
        voterChoices[_electionId][_voter].hasVoted = true;
    }

    function addVotesToCount(uint8 _firstChoice, uint8 _secondChoice, uint8 _thirdChoice, uint _electionId) external {

        // Get the candidates for the election
        string[] memory candidates = elections[_electionId].candidates;

        // Get the candidates' vote count
        CandidatesVoteCount storage candidateVoteCount = candidatesVoteCount[_electionId][candidates[_firstChoice]];

        // Add the votes to the candidates' vote count
        candidateVoteCount.firstChoiceVotes += 1;

        // Get the candidates' vote count
        candidateVoteCount = candidatesVoteCount[_electionId][candidates[_secondChoice]];

        // Add the votes to the candidates' vote count
        candidateVoteCount.secondChoiceVotes += 1;

        // Get the candidates' vote count
        candidateVoteCount = candidatesVoteCount[_electionId][candidates[_thirdChoice]];

        // Add the votes to the candidates' vote count
        candidateVoteCount.thirdChoiceVotes += 1;
    }

    /**
     * @dev Function to add votes to the contract
     * @param _electionId The ID of the election to add votes to
     * @param _votes The list of votes to add
     */
    function checkElection(uint8[] memory _votes, uint _electionId) external view{
        // require election exists
        require(_electionId > 0 && _electionId < electionCount, "Election does not exist");
        // require that the election is open
        require (elections[_electionId].electionOpen == true, "Election is closed");
        // Require the right amount of votes
        require (_votes.length == elections[_electionId].candidates.length, "The amount of votes does not match the amount of candidates");
        
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

    // Function to get the vote count for a candidate
    function getCandidateVoteCount(uint _electionId, string memory _candidate) public view returns (uint, uint, uint) {
        return (
            candidatesVoteCount[_electionId][_candidate].firstChoiceVotes,
            candidatesVoteCount[_electionId][_candidate].secondChoiceVotes,
            candidatesVoteCount[_electionId][_candidate].thirdChoiceVotes
        );
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



