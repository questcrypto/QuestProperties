/*------>Testing the Proxy<------*/
// Load dependencies
const { expect } = require("chai")
const { deployProxy } = require("@openzeppelin/truffle-upgrades")

// Load compiled artifacts
const QuestProperties = artifacts.require("QuestProperties")

contract("Quest Properties (proxy)", function (accounts) {
	const treasury = accounts[0]
	const upgrader = accounts[0]
	const baseURI = "https://quest-test.herokuapp.com/"
	const _noOfRights = 5
	beforeEach(async function () {
		// Deploy a new property contract for each test
		this.questproperties = await deployProxy(
			QuestProperties,
			[treasury, upgrader, baseURI, _noOfRights],
			{ initializer: "initialize" }
		)
	})

	// Test case
	it("retrieve returns a value that was initialized", async function () {
		const result = await this.questproperties.mintNFT(0, "0x0", 0, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 0)
	})
})
