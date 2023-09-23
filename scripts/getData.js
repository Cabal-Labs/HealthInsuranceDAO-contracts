const hre = require("hardhat")
const ethers = require("ethers")

const contract = require("../deployments/mumbai/contract.json")

async function main() {
    // Connect to the contract using the first signer
    const signer = await hre.ethers.getSigners()
    const deployerWallet = signer[0]
    const contract = new ethers.Contract(contract.address, contract.abi, deployerWallet)

    const patient = "0x8cF84867ba54bd078F678fb276BB1a103efce7d3"
}

main().catch((error) => {
    console.error(error.message)
    process.exitCode = 1
})
