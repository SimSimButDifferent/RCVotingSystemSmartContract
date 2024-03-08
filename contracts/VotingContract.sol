// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

/* Imports */
import "./IBallotContract.sol";

/* Events */
// Event to record when a vote is counted
    event VoteCast(
        address indexed voter,
        string[] rankedChoices
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

    // Bool to track if a voter has voted or not
    bool hasVoted = false;

    /* Constructor */
    // Set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    /* Structs */
    // Struct to store a voter's ranked choices
    struct VoterChoices {
        string[] rankedChoices;
        bool hasVoted;
    }

    /* Mappings */
    // Mapping of voter address to their ranked choices
    mapping(address => VoterChoices) public voterChoices;

    /* Modifiers */

    /* Functions */
    /* Function to vote on a ballot
     * @param _votes The ranked choices of the voter
     */
    function vote(
        string[] memory _votes, uint _electionId
    ) public {
        require(
            voterChoices[msg.sender].hasVoted == false,
            "Voter has already voted"
        );
        

        // Create a new voter choice
        VoterChoices memory voterChoice = VoterChoices(
            _votes,
            hasVoted = true
        );

        // Record the voter's choices
        voterChoices[msg.sender] = voterChoice;

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
    function getVoterStatus(address _voter)
        public
        view
        returns (bool)
    {
        return voterChoices[_voter].hasVoted;
    }
    

    // Function to get a voter's ranked choices
    function getVoterChoices(
        address _voter
    ) public view returns (string[] memory) {
        require(
            voterChoices[_voter].hasVoted == true,
            "Voter has not voted"
        );
        return (
            voterChoices[_voter].rankedChoices
        );
    }
}
