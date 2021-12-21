const QuestProperties = artifacts.require("QuestProperties");

contract("1st Quest Property Test", async accounts => {
  const treasury = accounts[0];
  const upgrader = accounts[0];
  const baseURI = "https://quest-test.herokuapp.com/";
  const _noOfRights = 5;
  it("Initializing property contract", async () => { 
    const instance = await QuestProperties.deployed();
    await instance.initialize(
      treasury,
      upgrader,
      baseURI,
      _noOfRights,
    );
    let tempnoOfRights = 0;
    await instance.noOfRights.call(function (err, res) {
      tempnoOfRights = res;
  });
    assert.equal(tempnoOfRights, _noOfRights);
  })
  it("Testing mint NFT: Price 0 then we mint TITLE", async () => { 
    const instance = await QuestProperties.deployed();
    const result = await instance.mintNFT(0, "0x0", 0, { from: accounts[0] })
    assert.equal(result.logs[0].args.id.valueOf(), 0);
    const supplyForTitleNFT = await instance.totalSupply(0);
    console.log(supplyForTitleNFT, 1)
  })
  
});