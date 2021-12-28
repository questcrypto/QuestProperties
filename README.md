# QuestProperties

### In live Production, truffle-config shouldn't have keys hard coded in the file.

#### @John Barlow:
 - Need list of NFTs with Zero Values to finish pricing list 


#### @Arhan & @Chethan:
- Review Code in ERC1155, with special attention to `burnNFT` , `burnBatchNFTs`, & `transferNFT`.
- if you are gonna into errors, please check modifiers & requirements and let me know
- I would be thrilled if you can enhance my code &/or calling functions

####  @Front End:
- contract Interfaces, which are three in ERC1155 have to be prioritized by FE team

#### @Chethan:
- responsible for USDC pricing as it's already listed as mapped asset on Polygon Blockchain.

#### @Arhan:
- Writing full test for ERC1155 using upgradeables-plugin


</P> 

## Notes about the contract to facilitate dealing with:

* ERC1155 will be deployed first, address will be used in Factory
* Factory Contract: ERC1155 address is immutable and whoever call the initialized function will be the contract owner (HOA)
* each time a new proxy is created, the address of the proxy will stored in an array of proxies and an event will be emitted with proxy address
* In ERC1155, HOA is the owner & Default Admin Role which is responsible to:
    
    1- `approvedProperty`

    2- `burnNFT` & `burnBatchNFTs`

    3- `transferNFT`

    4- `Pausing` Factory contract in case of bugs or Emergency

* TREASURY_ROLE : responsible for `mintNFT ` & `mintBatchNFTs`

* UPGRADER_ROLE : responsible for `upgradeTo` to the new version

<P>

### Myself:
- My work is done unless we run into bugs.


