const hre = require("hardhat")
const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

async function main() {
    if (developmentChains.includes(network.name)) {
        // Deploy the BallotContract
        const BallotContract =
            await hre.ethers.getContractFactory("BallotContract")

        console.log("Deploying BallotContract...")

        const ballotContract = await BallotContract.deploy()
        const ballotContractAddress = ballotContract.target
        console.log(`BallotContract deployed to: ${ballotContractAddress}`)

        // Deploy the VotingContract
        const VotingContract =
            await hre.ethers.getContractFactory("VotingContract")

        console.log("Deploying VotingContract...")

        const votingContract = await VotingContract.deploy(
            ballotContractAddress,
        )
        console.log(`VotingContract deployed to: ${votingContract.target}`)
    }

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        // Deploy the BallotContract
        const BallotContract =
            await hre.ethers.getContractFactory("BallotContract")

        console.log("Deploying BallotContract...")

        const desiredConfirmations = 6

        const ballotContract = await BallotContract.deploy()
        const ballotContractAddress = ballotContract.target
        console.log(`BallotContract deployed to: ${ballotContractAddress}`)

        const ballotReceipt = await ballotContract
            .deploymentTransaction()
            .wait(desiredConfirmations)

        console.log(
            `Transaction confirmed. Block number: ${ballotReceipt.blockNumber}`,
        )
        await hre.run("verify:etherscan", { address: ballotContractAddress })
        console.log("BallotContract verified!")
        console.log("--------------------------------------------------")

        // Deploy the VotingContract
        const VotingContract =
            await hre.ethers.getContractFactory("VotingContract")

        console.log("Deploying VotingContract...")

        const votingContract = await VotingContract.deploy(
            ballotContractAddress,
        )

        const votingContractAddress = votingContract.target
        console.log(`VotingContract deployed to: ${votingContractAddress}`)

        const votingReceipt = await votingContract
            .deploymentTransaction()
            .wait(desiredConfirmations)

        console.log(
            `Transaction confirmed. Block number: ${votingReceipt.blockNumber}`,
        )
        await hre.run("verify:verify", {
            address: votingContractAddress,
            constructorArguments: [ballotContractAddress],
        })
        console.log("VotingContract verified!")
        console.log("--------------------------------------------------")
    }
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
