const QuestProperties = artifacts.require("QuestProperties")

contract("1st Quest Property Test", async accounts => {
	const treasury = accounts[0]
	const upgrader = accounts[0]
	const baseURI = "https://quest-test.herokuapp.com/"
	const _noOfRights = 5

	it("Initializing property contract", async () => {
		const instance = await QuestProperties.deployed()
		await instance.initialize(treasury, upgrader, baseURI, _noOfRights)
		let tempnoOfRights = 0
		await instance.noOfRights.call(function (err, res) {
			tempnoOfRights = res
		})
		assert.equal(tempnoOfRights, _noOfRights)
	})
	it("Testing mint NFT: Price 0 then we mint TITLE", async () => {
		const instance = await QuestProperties.deployed()
		const result = await instance.mintNFT(0, "0x0", 0, { from: accounts[0] })
		assert.equal(result.logs[0].args.id.valueOf(), 0)
		const existsResult = await instance.exists(0)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:1", async () => {
		const instance = await QuestProperties.deployed()
		const result = await instance.mintNFT(1, "0x0", 100, { from: accounts[0] })
		assert.equal(result.logs[0].args.id.valueOf(), 1)
		// assert.equal(result.logs[0].args.price.valueOf(), 100)
		let existsResult = await instance.exists(1)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:2", async () => {
		const instance = await QuestProperties.deployed()
		const result = await instance.mintNFT(2, "0x0", 90, { from: accounts[0] })
		assert.equal(result.logs[0].args.id.valueOf(), 2)
		// assert.equal(result.logs[0].args.price.valueOf(), 90)
		let existsResult = await instance.exists(2)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:3", async () => {
		const instance = await QuestProperties.deployed()
		const result = await instance.mintNFT(3, "0x0", 80, { from: accounts[0] })
		assert.equal(result.logs[0].args.id.valueOf(), 3)
		// assert.equal(result.logs[0].args.price.valueOf(), 80)
		let existsResult = await instance.exists(3)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:4", async () => {
		const instance = await QuestProperties.deployed()
		const result = await instance.mintNFT(4, "0x0", 70, { from: accounts[0] })
		assert.equal(result.logs[0].args.id.valueOf(), 4)
		// assert.equal(result.logs[0].args.value.valueOf(), 70)
		let existsResult = await instance.exists(4)
		assert.equal(existsResult, true)
	})
	it("Testing mint NFT: Minting the right with ID:5", async () => {
		const instance = await QuestProperties.deployed()
		const result = await instance.mintNFT(5, "0x0", 60, { from: accounts[0] })
		assert.equal(result.logs[0].args.id.valueOf(), 5)
		// assert.equal(result.logs[0].args.value.valueOf(), 60)
		let existsResult = await instance.exists(5)
		assert.equal(existsResult, true)
	})
	//Batch minting is being revrted because of excess gas fees
	/* it("Testing mintBatchNFTs: Minting from ids 1 to 5", async () => {
		const instance = await QuestProperties.deployed()
		// let ids = [1, 2, 3, 4, 5]
		let ids = [1, 2]
		// let amounts = [1, 1, 1, 1, 1]
		let amounts = [1, 1]
		// let data = ["0x0", "0x0", "0x0", "0x0", "0x0"]
		let data = ["0x0", "0x0"]
		// let prices = [100, 90, 80, 70, 60]
		let prices = [100, 90]
		const result = await instance.mintBatchNFTs(ids, amounts, data, prices, {
			from: accounts[0],
			gas: 3000000,
		})
		console.log(result.logs[0].args)
		// assert.equal(result.logs[0].args.id.valueOf(), 5)
		// assert.equal(result.logs[0].args.value.valueOf(), 60)
		let existsResult1 = await instance.exists(1)
		let existsResult2 = await instance.exists(2)
		let existsResult3 = await instance.exists(3)
		let existsResult4 = await instance.exists(4)
		let existsResult5 = await instance.exists(5)
		assert.equal(existsResult1, true)
		assert.equal(existsResult2, true)
		assert.equal(existsResult3, true)
		assert.equal(existsResult4, true)
		assert.equal(existsResult5, true)
	}) */
})
