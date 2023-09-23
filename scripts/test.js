const hre = require("hardhat")
const ethers = require("ethers")

const contract = require("../deployments/goerli/Treasury.json")

async function main() {
    // Connect to the contract using the first signer
    const signer = await hre.ethers.getSigners()
    const deployerWallet = signer[0]
    const contract_use = new ethers.Contract(contract.address, contract.abi, deployerWallet)

    let result = await contract_use.getPremium(0)

    console.log(result.toString())
}

main().catch((error) => {
    console.error(error.message)
    process.exitCode = 1
})
