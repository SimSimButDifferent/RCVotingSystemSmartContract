const { expect } = require("chai")
const { ethers } = require("hardhat")
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers")

describe("BallotContract", function () {
    let BallotContract, ballotContract, owner, addr1, vote, vote1, vote2, vote3

    beforeEach(async function () {
        BallotContract = await ethers.getContractFactory("BallotContract")
        ;[owner, addr1] = await ethers.getSigners()
        ballotContract = await BallotContract.deploy()
    })

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await ballotContract.getOwner()).to.equal(owner.address)
        })
    })

    describe("voteBallot", function () {
        it("Reverts if voter has already voted", async function () {
            vote1 = "Candidate 1"
            vote2 = "Candidate 2"
            vote3 = "Candidate 3"
            vote = await ballotContract
                .connect(addr1)
                .voteBallot(vote1, vote2, vote3)
            await vote.wait()

            expect(
                await ballotContract.voteBallot(vote1, vote2, vote3),
            ).to.be.revertedWith("Voter has already voted")
        })

        it("Should allow voting", async function () {
            vote1 = "Candidate 1"
            vote2 = "Candidate 2"
            vote3 = "Candidate 3"
            vote = await ballotContract
                .connect(addr1)
                .voteBallot(vote1, vote2, vote3)
            expect(await ballotContract.getVoterChoices(addr1)).to.deep.equal([
                vote1,
                vote2,
                vote3,
            ])
        })

        it("Should emit a VoteCast event", async function () {
            vote1 = "Candidate 1"
            vote2 = "Candidate 2"
            vote3 = "Candidate 3"
            vote = await ballotContract
                .connect(addr1)
                .voteBallot(vote1, vote2, vote3)
            await expect(vote).to.emit(ballotContract, "VoteCast")
        })
    })

    describe("getVoterChoices", function () {
        it("Should revert if account has not voted", async function () {
            await expect(
                ballotContract.getVoterChoices(addr1),
            ).to.be.revertedWith("Voter has not voted")
        })
    })
})

describe("VotingContract", function () {
    let VotingContract,
        votingContract,
        owner,
        addr1,
        candidatesList,
        candidate1,
        candidate2,
        candidate3,
        electionTimeLimit,
        electionStartTime,
        electionEndTime

    beforeEach(async function () {
        VotingContract = await ethers.getContractFactory("VotingContract")
        ;[owner, addr1] = await ethers.getSigners()
        votingContract = await VotingContract.deploy()

        candidate1 = "Candidate 1"
        candidate2 = "Candidate 2"
        candidate3 = "Candidate 3"
    })

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await votingContract.getOwner()).to.equal(owner.address)
        })
    })

    describe("addElection", function () {
        beforeEach(async function () {
            electionTimeLimit = 1

            await votingContract.addElection(
                [candidate1, candidate2, candidate3],
                electionTimeLimit,
            )

            candidatesList = await votingContract.getElectionCandidates(1)
            electionStatus = await votingContract.getElectionStatus(1)
            electionStartTime = await votingContract.getElectionStartTime(1)
            electionEndTime = await votingContract.getElectionEndTime(1)
        })

        it("onlyOwner can add an election", async function () {
            await expect(
                votingContract
                    .connect(addr1)
                    .addElection(
                        ["Candidate 1", "Candidate 2", "Candidate 3"],
                        electionTimeLimit,
                    ),
            ).to.be.revertedWith("Only the owner can call this function")
        })
        it("Reverts is there is only one candidate", async function () {
            await expect(
                votingContract.addElection(["only1Candidate"], 1),
            ).to.be.revertedWith("There must be more than one candidate")
        })

        it("Reverts if there are more than 5 candidates", async function () {
            await expect(
                votingContract.addElection(
                    [
                        "Candidate1/6",
                        "Candidate2/6",
                        "Candidate3/6",
                        "Candidate4/6",
                        "Candidate5/6",
                        "Candidate6/6",
                    ],
                    electionTimeLimit,
                ),
            ).to.be.revertedWith(
                "An election can have a maximum of 5 candidates",
            )
        })

        it("Should have ElectionStatus notCreated if electionId has not been used", async function () {
            expect(await votingContract.getElectionStatus(10)).to.equal(0)
        })

        it("Succesfully creates and maps an election", async function () {
            expect(await votingContract.getElection(1)).to.deep.equal([
                candidatesList,
                electionStartTime,
                electionEndTime,
                electionStatus,
            ])
        })

        it("Should correctly set electionStatus enum to open", async function () {
            expect(await votingContract.getElectionStatus(1)).to.equal(1)
        })

        it("Should incriment the Election count after each election", async function () {
            const electionCount = await votingContract.getElectionCount()
            const counterIncriment = ethers.parseUnits("1", 0)
            await votingContract.addElection(
                ["Candidate 1", "Candidate 2", "Candidate 3"],
                electionTimeLimit,
            )
            expect(await votingContract.getElectionCount()).to.equal(
                electionCount + counterIncriment,
            )
        })

        it("Should emit an ElectionCreated event", async function () {
            await expect(
                votingContract.addElection(
                    ["Candidate 1", "Candidate 2", "Candidate 3"],
                    electionTimeLimit,
                ),
            ).to.emit(votingContract, "ElectionCreated")
        })
    })

    describe("closeElection", function () {
        beforeEach(async function () {
            electionTimeLimit = 1

            await votingContract.addElection(
                [candidate1, candidate2, candidate3],
                electionTimeLimit,
            )

            await time.increase(electionTimeLimit * 24 * 60 * 60)
        })

        it("onlyOwner can close an election", async function () {
            await expect(
                votingContract.connect(addr1).closeElection(1),
            ).to.be.revertedWith("Only the owner can call this function")
        })

        it("Reverts if election does not exist", async function () {
            await expect(votingContract.closeElection(0)).to.be.revertedWith(
                "Election does not exist",
            )
            await expect(votingContract.closeElection(100)).to.be.revertedWith(
                "Election does not exist",
            )
        })

        it("Reverts if election is already closed", async function () {
            const closedElection = await votingContract.closeElection(1)
            closedElection.wait()
            await expect(votingContract.closeElection(1)).to.be.revertedWith(
                "Election is already closed",
            )
        })

        it("Succesfully closes an election and sets status to closed", async function () {
            const closedElection = await votingContract.closeElection(1)
            await closedElection.wait()
            expect(await votingContract.getElectionStatus(1)).to.equal(2)
        })
    })
})
