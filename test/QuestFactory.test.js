/*------>Testing the Proxy<------*/
// Load dependencies
const { expect } = require("chai")
const { deployProxy } = require("@openzeppelin/truffle-upgrades")

// Load compiled artifacts
const QuestFactory = artifacts.require("QuestFactory")
const QuestProperties = artifacts.require("QuestProperties")

contract("Quest Factory (test)", function (accounts) {
	const treasury = accounts[0]
	const upgrader = accounts[0]
	const baseURI = "https://quest-test.herokuapp.com/"
	const contractName = "Quest Properties Tests"
	const description = "Testing the contract"
	beforeEach(async function () {
		// Deploy a new property contract for each property
		this.questFactory = await deployProxy(
			QuestFactory,
			{ initializer: "initialize" },
			{ kind: "uups" }
		)
	})

	// Test case
	it("retrieve returns a value that was initialized", async function () {
		const proxyAddress = await this.questFactory.deployPropertyContract(
			treasury,
			upgrader,
			baseURI,
			contractName,
			description,
			{
				from: accounts[0],
			}
		)
		console.log(proxyAddress)
		let questPropertyInstance = await QuestProperties.at(proxyAddress)
		console.log(questPropertyInstance)
	})
})
