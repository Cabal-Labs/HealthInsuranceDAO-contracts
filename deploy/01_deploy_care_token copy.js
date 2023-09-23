require("hardhat-deploy")
require("hardhat-deploy-ethers")

const { networkConfig } = require("../helper-hardhat-config")

const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    const { deploy } = deployments

    const caretoken = await deploy("CareToken", {
        from: wallet.address,
        log: true,
    })

    console.log("deployed CareToken")
}

module.exports.tags = ["CareToken"]
