require("hardhat-deploy")
require("hardhat-deploy-ethers")
const { unlock } = require("hardhat")

const { networkConfig } = require("../helper-hardhat-config")

const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    const { deploy } = deployments

    console.log("deploying membership")

    const treasury_address = "0x3FE96Fd6ff721B15d5946CBb301AADEc7C0928C7"

    const Treasury = await deploy("Treasury", {
        from: wallet.address,
        args: [treasury_address],
        log: true,
    })

    const treasury = await ethers.getContractAt("Treasury", Treasury.address)

    // create a lock
    const lockArgs = {
        expirationDuration: 60 * 60 * 24 * 7, // 7 days
        currencyContractAddress: null, // null for ETH or erc20 address
        keyPrice: "100000000", // in wei
        maxNumberOfKeys: 10,
        name: "Basic Policy",
    }

    console.log("right before")
    // const a = await unlock.createLock(lockArgs)
    //await treasury.addMembershipToPolicy("0", a.lockAddress)
    const b = await treasury.addMembershipToPolicy(
        "0",
        "0xc62dd0e35f95b2a60537f91facf18e87c3a00609"
    )
    console.log("added membership to policy")
    //console.log("deployed membership:", a.lockAddress)
}

module.exports.tags = ["Treasury"]
