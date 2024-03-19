// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IBallotContract {
    /* Functions */
    function updateVoterChoices(
        uint8 _firstChoice,
        uint8 _secondChoice,
        uint8 _thirdChoice,
        uint _electionId,
        address _voter
    ) external;

    function addVotesToCount(
        uint8 _firstChoice,
        uint8 _secondChoice,
        uint8 _thirdChoice,
        uint _electionId
    ) external;

    function checkElection(uint8[] memory _votes, uint _electionId) external;

    function getElectionStatus(uint _electionId) external view returns (bool);

    function getElectionCandidates(
        uint _electionId
    ) external view returns (string[] memory);

    function getVoterStatus(
        address _voter,
        uint _electionId
    ) external view returns (bool);

    function getVoterChoices(
        address _voter,
        uint _electionId
    ) external view returns (uint8, uint8, uint8);
}
