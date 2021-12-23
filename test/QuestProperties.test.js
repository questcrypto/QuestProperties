//Load dependencies
const { expect } = require("chai")

//Load compiled artiacts
const QuestProperties = artifacts.require("QuestProperties")

//Test Case 1
contract("1st Quest Property Test", async accounts => {
	const treasury = accounts[0]
	const upgrader = accounts[0]
	const baseURI = "https://quest-test.herokuapp.com/"
	const _noOfRights = 5
	beforeEach(async () => {
		//Deploy the contract
		this.contract = await QuestProperties.new()
		//Initialising by calling the initialize function
		await this.contract.initialize(treasury, upgrader, baseURI, _noOfRights)
	})
	//----->For mintNFT<-----//
	it("Testing mint NFT: Price 0 then we mint TITLE", async () => {
		const result = await this.contract.mintNFT(0, "0x0", 0, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 0)
		const existsResult = await this.contract.exists(0)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:1", async () => {
		const result = await this.contract.mintNFT(1, "0x0", 100, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 1)
		// assert.equal(result.logs[0].args.price.valueOf(), 100)
		let existsResult = await this.contract.exists(1)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:2", async () => {
		const result = await this.contract.mintNFT(2, "0x0", 90, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 2)
		// assert.equal(result.logs[0].args.price.valueOf(), 90)
		let existsResult = await this.contract.exists(2)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:3", async () => {
		const result = await this.contract.mintNFT(3, "0x0", 80, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 3)
		// assert.equal(result.logs[0].args.price.valueOf(), 80)
		let existsResult = await this.contract.exists(3)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:4", async () => {
		const result = await this.contract.mintNFT(4, "0x0", 70, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 4)
		// assert.equal(result.logs[0].args.value.valueOf(), 70)
		let existsResult = await this.contract.exists(4)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:5", async () => {
		const result = await this.contract.mintNFT(5, "0x0", 60, {
			from: accounts[0],
		})
		assert.equal(result.logs[0].args.id.valueOf(), 5)
		// assert.equal(result.logs[0].args.value.valueOf(), 60)
		let existsResult = await this.contract.exists(5)
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
		const result = await this.contract.mintBatchNFTs(
			ids,
			amounts,
			data,
			prices,
			{
				from: accounts[0],
				gas: 3000000,
			}
		)
		console.log(result.logs[0].args)
		// assert.equal(result.logs[0].args.id.valueOf(), 5)
		// assert.equal(result.logs[0].args.value.valueOf(), 60)
		let existsResult1 = await this.contract.exists(1)
		let existsResult2 = await this.contract.exists(2)
		let existsResult3 = await this.contract.exists(3)
		let existsResult4 = await this.contract.exists(4)
		let existsResult5 = await this.contract.exists(5)
		assert.equal(existsResult1, true)
		assert.equal(existsResult2, true)
		assert.equal(existsResult3, true)
		assert.equal(existsResult4, true)
		assert.equal(existsResult5, true)
	})
	//----->For burnNFT<----//
	it("Testing burn NFT: Burning the right with ID:5", async () => {
		await this.contract.mintNFT(5, "0x0", 60, {
			from: accounts[0],
		})
		let existsResult1 = await this.contract.exists(5)
		console.log(existsResult1)
		assert.equal(existsResult1, true)
		if (existsResult1) {
			await this.contract.burnNFT(accounts[0], 5, 1, {
				from: accounts[0],
			})
		}
	})
})
