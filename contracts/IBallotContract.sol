// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IBallotContract {
    /* Functions */

    /**
     * @dev Updates the voter's choices for the election.
     * @param _firstChoice First choice candidate number.
     * @param _secondChoice Second choice candidate number.
     * @param _thirdChoice Third choice candidate number.
     * @param _electionId Election ID.
     * @param _voter Voter address.
     */
    function updateVoterChoices(
        uint8 _firstChoice,
        uint8 _secondChoice,
        uint8 _thirdChoice,
        uint _electionId,
        address _voter
    ) external;

    /**
     * @dev Adds the votes to the candidate count.
     * @param _firstChoice First choice candidate number.
     * @param _secondChoice Second choice candidate number.
     * @param _thirdChoice Third choice candidate number.
     * @param _electionId Election ID.
     */
    function addVotesToCount(
        uint8 _firstChoice,
        uint8 _secondChoice,
        uint8 _thirdChoice,
        uint _electionId
    ) external;

    /**
     * @dev Checks the election status.
     * @param _votes Array of votes.
     * @param _electionId Election ID.
     */
    function checkElection(uint8[] memory _votes, uint _electionId) external;

    /**
     * @dev Returns the election status.
     * @param _electionId Election ID.
     */
    function getElectionStatus(uint _electionId) external view returns (bool);

    /**
     * @dev Returns the election candidates.
     * @param _electionId Election ID.
     */
    function getElectionCandidates(
        uint _electionId
    ) external view returns (string[] memory);

    /**
     * @dev Returns the status of a given voter.
     * @param _voter Voter address.
     * @param _electionId Election ID.
     */
    function getVoterStatus(
        address _voter,
        uint _electionId
    ) external view returns (bool);

    /**
     * @dev Returns the given voter's choices.
     * @param _voter Voter address.
     * @param _electionId Election ID.
     */
    function getVoterChoices(
        address _voter,
        uint _electionId
    ) external view returns (uint8, uint8, uint8);
}
