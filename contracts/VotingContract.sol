// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

/* Imports */
import "./IBallotContract.sol";

/* Events */
// Event to record when a vote is counted
    event VoteCast(
        address indexed voter,
        uint8[] rankedChoices
    );



/**
 * @title VotingContract
 * @dev Contract to manage individual votes, recording voters' ranked choices for candidates.
 * Also store votes and interact with the BallotContract
 */
contract VotingContract {
    /* State Variables */
    address private owner;

    // BallotContract instance
    IBallotContract private ballotContract;

    bool private hasVoted;

    /* Constructor */
    // Set the owner of the contract
    constructor(address _ballotContractAddress) {
        owner = msg.sender;
        ballotContract = IBallotContract(_ballotContractAddress);
    }

    // Mapping to store a voters voting status
    mapping(uint => mapping(address => bool)) public voted;

    /* Functions */
    /* Function to vote on a ballot
     * @param _votes The ranked choices of the voter
     */

    function addVotes(
        uint8[] memory _votes, uint _electionId
    ) public {
        // require voter has not voted
        require(
            voted[_electionId][msg.sender] == false,
            "Voter has already voted"
        );
        
        // Add the votes to the BallotContract
        ballotContract.checkElection(_votes, _electionId);
        
        // Update the voter's choices in the BallotContract
        ballotContract.updateVoterChoices(_votes[0],_votes[1], _votes[2], _electionId, msg.sender);

        hasVoted = true;

        // Set the voter's vote status to true
        voted[_electionId][msg.sender] = hasVoted;

        // Emit the VoteCast event
        emit VoteCast(msg.sender, _votes);
    }

    

   
    /* Getter Functions */
    // Function to get the owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }

    // Function to get the election status
     function getElectionStatus(uint _electionId) public view returns (bool) {
        return ballotContract.getElectionStatus(_electionId);
    }


    // Function to get election candidates
    function getElectionCandidates(uint _electionId)
        external
        view
        returns (string[] memory)
    {
        return ballotContract.getElectionCandidates(_electionId);
    }

    // Function to get a voter's vote status
    function getVoterStatus(address _voter, uint _electionId)
        public
        view
        returns (bool)
    {
        return ballotContract.getVoterStatus(_voter, _electionId);
    }
    
    // Function to get a voter's ranked choices
    function getVoterChoices(
        address _voter, uint _electionId
    ) public view returns (uint8, uint8, uint8) {
        require(
            voted[_electionId][_voter] == true,
            "Voter has not voted"
        );
        return ballotContract.getVoterChoices(_voter, _electionId);
    }

}
