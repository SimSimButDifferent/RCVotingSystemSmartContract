const { expect } = require("chai")
const { ethers } = require("hardhat")

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
    let VotingContract, votingContract, owner, addr1, addr2, addr3, addr4, vote

    beforeEach(async function () {
        VotingContract = await ethers.getContractFactory("VotingContract")
        ;[owner, addr1, addr2, addr3, addr4] = await ethers.getSigners()
        votingContract = await VotingContract.deploy()
    })

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await votingContract.getOwner()).to.equal(owner.address)
        })
    })
})
