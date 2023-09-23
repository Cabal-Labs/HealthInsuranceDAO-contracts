require("hardhat-deploy")
require("hardhat-deploy-ethers")

const { networkConfig } = require("../helper-hardhat-config")

const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    const { deploy } = deployments

    console.log("deploying treasury")

    const treasury_address = "0x3FE96Fd6ff721B15d5946CBb301AADEc7C0928C7"

    const Treasury = await deploy("Treasury", {
        from: wallet.address,
        args: [treasury_address],
        log: true,
    })
    console.log("deployed!")

    const treasury = await ethers.getContractAt("Treasury", Treasury.address)

    console.log("Adding Medical Codes")
    let a = ethers.utils.parseUnits("100", 18)
    let b = ethers.utils.parseUnits("100", 18)
    await treasury.addProcedure(450501007, a, 1) //CT Scan
    await treasury.addProcedure(399208008, b, 2) //Mammogram

    const currentGasPrice = await ethers.provider.getGasPrice()
    const gasPrice = currentGasPrice.mul(2)

    console.log("Adding Hospitals...")
    await treasury.addHospital("Carepoint Hosptial", wallet.address, { gasPrice })
    console.log("Creating Insurance Policy...")
    const policyName = "Basic Policy"
    const coverage = [450501007, 399208008] // Procedure codes covered by this policy
    await treasury.addInsurancePolicy(policyName, coverage)
}

module.exports.tags = ["Treasury"]
