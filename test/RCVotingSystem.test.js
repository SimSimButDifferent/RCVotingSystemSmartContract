const { expect } = require("chai")
const { ethers } = require("hardhat")
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers")

describe("VotingContract", function () {
    let VotingContract,
        votingContract,
        owner,
        addr1,
        vote,
        rankedChoices,
        BallotContract,
        ballotContract,
        ballotContractAddress,
        addElection,
        election1id,
        election2id,
        oneDay

    beforeEach(async function () {
        BallotContract = await ethers.getContractFactory("BallotContract")
        ballotContract = await BallotContract.deploy()
        ballotContractAddress = ballotContract.target
        VotingContract = await ethers.getContractFactory("VotingContract")
        ;[owner, addr1] = await ethers.getSigners()
        votingContract = await VotingContract.deploy(ballotContractAddress)
        rankedChoices = [1, 2, 3]

        addElection = await ballotContract.addElection(
            ["candidate 1", "candidate 2", "candidate 3"],
            1,
        )
        election1id = 1
        election2id = 2
        oneDay = 1
    })

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await votingContract.getOwner()).to.equal(owner.address)
        })
    })

    describe("vote", function () {
        it("Reverts if voter has already voted", async function () {
            vote = await votingContract
                .connect(addr1)
                .addVotes(rankedChoices, oneDay)
            await expect(
                votingContract.connect(addr1).addVotes(rankedChoices, 1),
            ).to.be.revertedWith("Voter has already voted")
        })

        it("Should allow a voter to vote", async function () {
            vote = await votingContract
                .connect(addr1)
                .addVotes(rankedChoices, oneDay)
            expect(
                await votingContract.getVoterChoices(addr1, election1id),
            ).to.deep.equal(rankedChoices)
        })

        it("Voter status updates correctly", async function () {
            expect(
                await votingContract.getVoterStatus(addr1, election1id),
            ).to.equal(false)

            vote = await votingContract
                .connect(addr1)
                .addVotes(rankedChoices, oneDay)
            expect(
                await votingContract.getVoterStatus(addr1, election1id),
            ).to.equal(true)
        })

        it("Should emit a VoteCast event", async function () {
            vote = await votingContract
                .connect(addr1)
                .addVotes(rankedChoices, oneDay)
            await expect(vote).to.emit(votingContract, "VoteCast")
        })
    })

    describe("getVoterChoices", function () {
        it("Should revert if account has not voted", async function () {
            await expect(
                votingContract.getVoterChoices(addr1, election1id),
            ).to.be.revertedWith("Voter has not voted")
        })
    })

    describe("VotingContract Interface functions", function () {
        it("Returns election candidates to Voting Contract", async function () {
            expect(await votingContract.getElectionCandidates(1)).to.deep.equal(
                ["candidate 1", "candidate 2", "candidate 3"],
            )
        })

        it("Returns election status to Voting Contract", async function () {
            expect(await votingContract.getElectionStatus(1)).to.equal(true)
        })
    })
})

describe("BallotContract", function () {
    let BallotContract,
        ballotContract,
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
        BallotContract = await ethers.getContractFactory("BallotContract")
        ;[owner, addr1] = await ethers.getSigners()
        ballotContract = await BallotContract.deploy()

        candidate1 = "Candidate 1"
        candidate2 = "Candidate 2"
        candidate3 = "Candidate 3"
    })

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await ballotContract.getOwner()).to.equal(owner.address)
        })
    })

    describe("addElection", function () {
        beforeEach(async function () {
            electionTimeLimit = 1

            await ballotContract.addElection(
                [candidate1, candidate2, candidate3],
                electionTimeLimit,
            )

            candidatesList = await ballotContract.getElectionCandidates(1)
            electionStatus = await ballotContract.getElectionStatus(1)
            electionStartTime = await ballotContract.getElectionStartTime(1)
            electionEndTime = await ballotContract.getElectionEndTime(1)
        })

        it("onlyOwner can add an election", async function () {
            await expect(
                ballotContract
                    .connect(addr1)
                    .addElection(
                        ["Candidate 1", "Candidate 2", "Candidate 3"],
                        electionTimeLimit,
                    ),
            ).to.be.revertedWith("Only the owner can call this function")
        })
        it("Reverts is there is only one candidate", async function () {
            await expect(
                ballotContract.addElection(["only1Candidate"], 1),
            ).to.be.revertedWith("There must be more than one candidate")
        })

        it("Reverts if there are more than 5 candidates", async function () {
            await expect(
                ballotContract.addElection(
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

        it("Succesfully creates and maps an election", async function () {
            expect(await ballotContract.getElection(1)).to.deep.equal([
                candidatesList,
                electionStartTime,
                electionEndTime,
                electionStatus,
            ])
        })

        it("Should correctly set electionOpen bool to true", async function () {
            expect(await ballotContract.getElectionStatus(1)).to.equal(true)
        })

        it("Should incriment the Election count after each election", async function () {
            const electionCount = await ballotContract.getElectionCount()
            const counterIncriment = ethers.parseUnits("1", 0)
            await ballotContract.addElection(
                ["Candidate 1", "Candidate 2", "Candidate 3"],
                electionTimeLimit,
            )
            expect(await ballotContract.getElectionCount()).to.equal(
                electionCount + counterIncriment,
            )
        })

        it("Adds electionId to openElections array", async function () {
            expect(await ballotContract.getOpenElections()).to.deep.equal([1])
        })

        it("Should emit an ElectionCreated event", async function () {
            await expect(
                ballotContract.addElection(
                    ["Candidate 1", "Candidate 2", "Candidate 3"],
                    electionTimeLimit,
                ),
            ).to.emit(ballotContract, "ElectionCreated")
        })
    })

    describe("closeElection", function () {
        beforeEach(async function () {
            electionTimeLimit = 1

            await ballotContract.addElection(
                [candidate1, candidate2, candidate3],
                electionTimeLimit,
            )

            await time.increase(electionTimeLimit * 24 * 60 * 60)
        })

        it("onlyOwner can close an election", async function () {
            await expect(
                ballotContract.connect(addr1).closeElection(1),
            ).to.be.revertedWith("Only the owner can call this function")
        })

        it("Reverts if election does not exist", async function () {
            await expect(ballotContract.closeElection(0)).to.be.revertedWith(
                "Election does not exist",
            )
            await expect(ballotContract.closeElection(100)).to.be.revertedWith(
                "Election does not exist",
            )
        })

        it("Reverts if election is already closed", async function () {
            const closedElection = await ballotContract.closeElection(1)
            closedElection.wait()
            await expect(ballotContract.closeElection(1)).to.be.revertedWith(
                "Election is already closed",
            )
        })

        it("Succesfully closes an election and sets status to closed", async function () {
            const closedElection = await ballotContract.closeElection(1)
            await closedElection.wait()
            expect(await ballotContract.getElectionStatus(1)).to.equal(false)
        })

        it("Should emit an ElectionClosed event", async function () {
            await expect(ballotContract.closeElection(1)).to.emit(
                ballotContract,
                "ElectionClosed",
            )
        })

        it("Should revert if time is not up", async function () {
            await ballotContract.addElection(
                [candidate1, candidate2, candidate3],
                electionTimeLimit,
            )
            await expect(ballotContract.closeElection(2)).to.be.revertedWith(
                "Election is still open",
            )
        })

        it("Adds electionId to closedElections array", async function () {
            const closedElection = await ballotContract.closeElection(1)
            await closedElection.wait()
            expect(await ballotContract.getClosedElections()).to.deep.equal([1])
        })

        it("Removes electionId from openElections array", async function () {
            const closedElection = await ballotContract.closeElection(1)
            await closedElection.wait()
            expect(await ballotContract.getOpenElections()).to.deep.equal([])
        })
    })
})
