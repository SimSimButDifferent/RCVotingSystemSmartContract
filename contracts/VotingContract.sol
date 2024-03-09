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
contract VotingContract is IBallotContract {
    /* State Variables */
    address private owner;

    IBallotContract ballotContract = IBallotContract(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);

    /* Constructor */
    // Set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    // Mapping to store a voters voting status
    mapping(address => bool) public voted;

    /* Functions */
    /* Function to vote on a ballot
     * @param _votes The ranked choices of the voter
     */
    function vote(
        uint8[] memory _votes, uint _electionId
    ) public {
        // require voter has not voted
        require(
            voted[msg.sender] == false,
            "Voter has already voted"
        );

        ballotContract.addVotes(_votes, _electionId);

        // Set the voter's vote status to true
        voted[msg.sender] = true;

        // Emit the VoteCast event
        emit VoteCast(msg.sender, _votes);
    }

    function addVotes(uint8[] memory _votes, uint _electionId) public {
        vote(_votes, _electionId);
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
    function getVoterStatus(address _voter)
        public
        view
        returns (bool)
    {
        return voted[_voter];
    }
    
    // Function to get a voter's ranked choices
    function getVoterChoices(
        address _voter
    ) public view returns (uint8, uint8, uint8) {
        require(
            voted[msg.sender] == true,
            "Voter has not voted"
        );
        return ballotContract.getVoterChoices(_voter);
    }

}
