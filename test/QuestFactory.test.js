/*------>Testing the Proxy<------*/
// Load dependencies
const { expect, assert } = require("chai")
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
	let questPropertyInstance
	beforeEach(async function () {
		// Deploy a new property contract for each property
		this.questFactory = await deployProxy(
			QuestFactory,
			{ initializer: "initialize" },
			{ kind: "uups" },
			{
				from: accounts[0],
			}
		)
		await this.questFactory.deployPropertyContract(
			treasury,
			upgrader,
			baseURI,
			contractName,
			description,
			{
				from: accounts[0],
				gas: 4712388,
				gasPrice: 100000000000,
			}
		)

		let lengthOfProxies = await this.questFactory.getProxyLength.call()
		let proxyAddress = await this.questFactory.proxies.call(lengthOfProxies - 1)
		questPropertyInstance = await QuestProperties.at(proxyAddress)
	})

	it("Matching base URI", async function () {
		const result = await questPropertyInstance.uri.call(1)
		assert.equal(result, baseURI)
	})

	// Test case
	it("retrieve returns a value that was initialized", async function () {
		await questPropertyInstance.approvedProperty("0x0", accounts[1], {
			from: accounts[0],
			gas: 4712388,
			gasPrice: 100000000000,
		})
		let propertiesDetails = await questPropertyInstance.properties.call(1)
	})

	//----->For mintNFT<-----//
	it("Testing mint NFT: Price 0 then we mint TITLE", async () => {
		const result = await questPropertyInstance.mintNFT(0, "0x0", 0, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 0)
		const existsResult = await questPropertyInstance.exists(0)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:1", async () => {
		const result = await questPropertyInstance.mintNFT(1, "0x0", 100, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 1)
		// assert.equal(result.logs[0].args.price.valueOf(), 100)
		let existsResult = await questPropertyInstance.exists(1)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:2", async () => {
		const result = await questPropertyInstance.mintNFT(2, "0x0", 90, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 2)
		// assert.equal(result.logs[0].args.price.valueOf(), 90)
		let existsResult = await questPropertyInstance.exists(2)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:3", async () => {
		const result = await questPropertyInstance.mintNFT(3, "0x0", 80, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 3)
		// assert.equal(result.logs[0].args.price.valueOf(), 80)
		let existsResult = await questPropertyInstance.exists(3)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:4", async () => {
		const result = await questPropertyInstance.mintNFT(4, "0x0", 70, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 4)
		// assert.equal(result.logs[0].args.value.valueOf(), 70)
		let existsResult = await questPropertyInstance.exists(4)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:5", async () => {
		const result = await questPropertyInstance.mintNFT(5, "0x0", 60, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 5)
		// assert.equal(result.logs[0].args.value.valueOf(), 60)
		let existsResult = await questPropertyInstance.exists(5)
		assert.equal(existsResult, true)
	})

	//----->For batch mint<----//
	it("Testing mintBatchNFTs: Minting from ids 1 to 5", async () => {
		// let ids = [1, 2, 3, 4, 5]
		let ids = [1, 2]
		// let amounts = [1, 1, 1, 1, 1]
		let amounts = [1, 1]
		// let data = ["0x0", "0x0", "0x0", "0x0", "0x0"]
		let data = ["0x0", "0x0"]
		// let prices = [100, 90, 80, 70, 60]
		let prices = [100, 90]
		const result = await questPropertyInstance.mintBatchNFTs(
			ids,
			amounts,
			data,
			prices,
			{
				from: accounts[0],
				gas: 3000000,
			}
		)
		// assert.equal(result.logs[0].args.id.valueOf(), 5)
		// assert.equal(result.logs[0].args.value.valueOf(), 60)
		let existsResult1 = await questPropertyInstance.exists(1)
		let existsResult2 = await questPropertyInstance.exists(2)
		let existsResult3 = await questPropertyInstance.exists(3)
		let existsResult4 = await questPropertyInstance.exists(4)
		let existsResult5 = await questPropertyInstance.exists(5)
		assert.equal(existsResult1, true)
		assert.equal(existsResult2, true)
		assert.equal(existsResult3, true)
		assert.equal(existsResult4, true)
		assert.equal(existsResult5, true)
	})
	//----->For burnNFT<----//
	it("Testing burn NFT: Burning the right with ID:5", async () => {
		await questPropertyInstance.mintNFT(5, "0x0", 60, {
			from: accounts[0],
		})
		let existsResult1 = await questPropertyInstance.exists(5)
		assert.equal(existsResult1, true)
		if (existsResult1) {
			await questPropertyInstance.burnNFT(accounts[0], 5, 1, {
				from: accounts[0],
			})
		}
	})
	//----->For burnBatchNFTs<----//
	it("Testing burn NFT: Burning the right with ID:5 & ID:4", async () => {
		await questPropertyInstance.mintNFT(5, "0x0", 60, {
			from: accounts[0],
		})
		await questPropertyInstance.mintNFT(4, "0x0", 70, {
			from: accounts[0],
		})
		let existsResult1 = await questPropertyInstance.exists(5)
		let existsResult2 = await questPropertyInstance.exists(4)
		assert.equal(existsResult1, true)
		assert.equal(existsResult2, true)
		let ids = [5, 4]
		let amounts = [1, 1]
		if (existsResult1 && existsResult2) {
			await questPropertyInstance.burnBatchNFTs(accounts[0], ids, amounts, {
				from: accounts[0],
			})
		}
	})
	it("Test getPropertyId() and totalSupply", async() => {
		await questPropertyInstance.mintNFT(5, "0x0", 60, {
			from: accounts[0],
		})
		await questPropertyInstance.mintNFT(4, "0x0", 70, {
			from: accounts[0],
		})
		const propertyIdOfProp = await questPropertyInstance.getPropertyId();
		assert.equal(propertyIdOfProp, 1);
		const supplyOfRightId4 = await questPropertyInstance.totalSupply(4)
		assert.equal(supplyOfRightId4, 1);
		const supplyOfRightId5 = await questPropertyInstance.totalSupply(5);
		assert.equal(supplyOfRightId5, 1);
	})
})
