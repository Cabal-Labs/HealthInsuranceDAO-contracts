require("hardhat-deploy")
require("hardhat-deploy-ethers")

const { networkConfig } = require("../helper-hardhat-config")

const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    const { deploy } = deployments

    console.log("deploying treasury")

    const treasury_address = "0x3FE96Fd6ff721B15d5946CBb301AADEc7C0928C7"

    const treasury_contract = await deploy("Treasury", {
        from: wallet.address,
        args: [treasury_address],
        log: true,
    })
    console.log("deployed!")

    let a = ethers.utils.parseUnits("100", 18)
    console.log(a.toString())
    await treasury_contract.addProcedure(450501007, 100)

    //add some medical codes
}

module.exports.tags = ["Treasury"]
