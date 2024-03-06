// SPDX-Identifier: MIT

pragma solidity 0.8.22;

/**
 * @title VotingContract
 * @dev Oversees the entire voting process, interacts with BallotContract to store votes.
 * Implements the logic for tallying votes based on RCV.
 */
contract VotingContract {
    /* State Variables */
    address private owner;

    constructor() {
        owner = msg.sender;
    }
}
