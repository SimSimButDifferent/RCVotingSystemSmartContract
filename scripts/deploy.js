const hre = require("hardhat")
const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

async function main() {
    if (developmentChains.includes(network.name)) {
        // Deploy the VotingContract
        const VotingContract =
            await hre.ethers.getContractFactory("VotingContract")

        console.log("Deploying VotingContract...")

        const votingContract = await VotingContract.deploy()
        console.log(`VotingContract deployed to: ${votingContract.target}`)

        // Deploy the BallotContract
        const BallotContract =
            await hre.ethers.getContractFactory("BallotContract")

        console.log("Deploying BallotContract...")

        const ballotContract = await BallotContract.deploy()
        console.log(`BallotContract deployed to: ${ballotContract.target}`)
    }

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        // Deploy the VotingContract
        const VotingContract =
            await hre.ethers.getContractFactory("VotingContract")

        console.log("Deploying VotingContract...")

        const votingContract = await VotingContract.deploy()
        console.log(`VotingContract deployed to: ${votingContract.target}`)

        const desiredConfirmations = 6
        const votingReceipt = await votingContract
            .deploymentTransaction()
            .wait(desiredConfirmations)

        console.log(
            `Transaction confirmed. Block number: ${votingReceipt.blockNumber}`,
        )
        await hre.run("verify:etherscan", { address: votingContract.target })
        console.log("VotingContract verified!")
        console.log("--------------------------------------------------")

        // Deploy the VotingContract
        const BallotContract =
            await hre.ethers.getContractFactory("BallotContract")

        console.log("Deploying VotingContract...")

        const ballotContract = await BallotContract.deploy()
        console.log(`BallotContract deployed to: ${ballotContract.target}`)

        const ballotReceipt = await votingContract
            .deploymentTransaction()
            .wait(desiredConfirmations)

        console.log(
            `Transaction confirmed. Block number: ${ballotReceipt.blockNumber}`,
        )
        await hre.run("verify:etherscan", { address: ballotContract.target })
        console.log("BallotContract verified!")
        console.log("--------------------------------------------------")
    }
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
