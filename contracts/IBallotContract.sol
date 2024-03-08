// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IBallotContract {
    /* Functions */

    function getElectionStatus(uint _electionId) external view returns (bool);

    function getElectionCandidates(
        uint _electionId
    ) external view returns (string[] memory);
}
