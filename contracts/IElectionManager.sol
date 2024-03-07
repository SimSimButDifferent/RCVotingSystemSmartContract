// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IElectionManager {
    /* Events */
    event ElectionCreated(
        uint indexed electionId,
        string[] candidates,
        uint electionEndTime
    );

    event ElectionClosed(uint indexed electionId);

    /* Enums */
    // Enum to track the status of an election
    enum ElectionStatus {
        notCreated,
        open,
        closed
    }

    /* Functions */

    function getElectionStatus(
        uint _electionId
    ) external view returns (ElectionStatus);

    function getElectionCandidates(
        uint _electionId
    ) external view returns (string[] memory);
}
