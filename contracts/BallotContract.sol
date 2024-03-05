// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

// This is a ballot contract that manages individual ballots and records voters ranked choices for ballots.
contract BallotContract {
    /* State Variables */
    address private owner;

    /* Constructor */
    // Set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    /* Enums */
    // Enum to track if a voter has voted or not
    enum Voted {
        hasNotVoted,
        hasVoted
    }

    /* Structs */
    // Struct to store a voter's ranked choices
    struct VoterChoices {
        string firstChoice;
        string secondChoice;
        string thirdChoice;
        Voted voted;
    }

    /* Mappings */
    // Mapping of voter address to their ranked choices
    mapping(address => VoterChoices) public voterChoices;

    /* Events */
    event VoteCounted(
        address indexed voter,
        string firstChoice,
        string secondChoice,
        string thirdChoice
    );

    /* Modifiers */

    /* Functions */
    /**
     * @dev Function to vote on a ballot
     * @param _vote1 The first choice of the voter
     * @param _vote2 The second choice of the voter
     * @param _vote3 The third choice of the voter
     */
    function voteBallot(
        string memory _vote1,
        string memory _vote2,
        string memory _vote3
    ) public {
        require(
            voterChoices[msg.sender].voted != Voted.hasVoted,
            "Voter has already voted"
        );

        // Create a new ballot
        VoterChoices memory voterChoice = VoterChoices(
            _vote1,
            _vote2,
            _vote3,
            Voted.hasVoted
        );

        // Record the voter's choices
        voterChoices[msg.sender] = voterChoice;

        // Emit the VoteCounted event
        emit VoteCounted(msg.sender, _vote1, _vote2, _vote3);
    }

    /* Getter Functions */
    // Function to get a voter's ranked choices
    function getVoterChoices(
        address _voter
    ) public view returns (string memory, string memory, string memory) {
        require(
            voterChoices[_voter].voted == Voted.hasVoted,
            "Voter has not voted"
        );
        return (
            voterChoices[_voter].firstChoice,
            voterChoices[_voter].secondChoice,
            voterChoices[_voter].thirdChoice
        );
    }

    // Function to get the owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }
}
