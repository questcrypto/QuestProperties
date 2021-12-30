// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 *@title Quest Properties
 *@author Strategic Quest Crypto
 *@dev This contract is based on data contract design pattern, where business logic contract
 * is separated from data contract to enable upgradeability of QuestProperties using UUPS.
 *
 * Strategic Quest web/dapp is semi-decentralized, where all required property & owner infos
 * is collected by JavaScript in FE, then processed internally into our smart contracts.
 * noting that property is only represented by one owner.
 *
 * Strategic Quest stores encrypted data of the property to blockchain using IPFS.
 *
 * AccessControlUpgradeable contract is inherited to segregate duties of each Role
 * ERC1155HolderUpgradeable contract is inherited to allow QuestProperties contract to hold NFTs
 * UUPSUpgradeable contract is the proxy used to upgrade QuestProperties contract
 */

contract QuestProperties is
    Initializable,
    ERC1155Upgradeable,
    ERC1155HolderUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter propertyIds;
    

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    bytes32 public constant CONTRACT_ADMIN_ROLE = keccak256("CONTRACT_ADMIN_ROLE");

    string public contractName;
    string public description;
    uint256 private propertyId;
    

    //Token data structure
    struct Token {
        uint256 id;
        uint256 price;
        uint256 timeStamp;
    }

    //Snapshot of property details
    struct Property {
        bytes parentHash;
        address propAddress;
        Token[] tokens;
    }

    //Array of only 6 tokens that are available to mint
    uint256[5] public availableTokens;

    //Granting propertyId to each property
    mapping(uint256 => Property) private properties;

    //Tracking each token id supply
    mapping(uint256 => uint256) private _totalSupply;

    //Ensure property is deployed only once.
    mapping(string => bool) private propertyExists;

    event PropertyAdded(uint256 propertyId, address property, bytes MerkleTree);

    //List of available tokens ids & their crossponding names
    uint256 public constant TITLE = 0;
    uint256 public constant MANAGEMENT_RIGHT = 1;
    uint256 public constant INCOME_RIGHT = 2;
    uint256 public constant EQUITY_RIGHT = 3;
    uint256 public constant OCCUPANCY_RIGHT = 4;
    uint256 public constant GOVERNANCE_RIGHT = 5;
    
    
    /**
     *@param treasury address, responsible for minting tokens
     *@param upgrader address, responsible for upgrading to next version
     *@param uri string, is json that represent the  physical property"https://game.example/api/item/{id}.json"
     *@param _contractName string, unique name given to each property
     *@param _description string, unique description that consist of tax id & other parameters.
     *
     *@dev DEFAULT_ADMIN_ROLE is HOA, it is the admin role for all roles, which means that only
     * accounts with this role will be able to grant or revoke other roles & also it's own admin.
     */
    function initialize(
        address treasury,
        address upgrader,
        address hoa,
        string memory uri,
        bytes memory _parentHash, 
        address _propAddress,
        string memory _contractName,
        string memory _description
        ) external 
        virtual 
        initializer {
        __ERC1155_init(uri);
        __AccessControl_init();
        __ERC1155Receiver_init();
        __ERC1155Holder_init();
        __UUPSUpgradeable_init();

        _setupRole(CONTRACT_ADMIN_ROLE, hoa);
        _setupRole(TREASURY_ROLE, treasury);
        _setupRole(UPGRADER_ROLE, upgrader);

        propertyExists[uri] = true;

        contractName = _contractName;
        description = _description;

        propertyIds.increment();
        propertyId = propertyIds.current();


        properties[propertyId].parentHash = _parentHash;
        properties[propertyId].propAddress = _propAddress;

        emit PropertyAdded(propertyId, _propAddress, _parentHash);

    }


    //@Arhan: cooperate with FE to support Interfaces
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC1155Upgradeable,
            AccessControlUpgradeable,
            ERC1155ReceiverUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //Getter function to get property id
    function getPropertyId() public view returns (uint256) {
        return propertyId;
    }

    //To get total supply of each token id
    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    //Returns total supply of each token id if token id exists
    function exists(uint256 id) public view virtual returns (bool) {
        return QuestProperties.totalSupply(id) > 0;
    }

    //Increment the version number in case of upgrading only
    function version() pure public virtual returns (string memory) {
        return 'Startegic Quest Crypto V1';
    }

    function getAddress() view public returns(address){
        return address(this);
    }

    /**
     *@param id uint, token id
     *@param data bytes, ipfs generated hash of token id
     *@param price uint, token price in USDC/Quest Coin
     *
     *Requirements:
     *
     * - TREASURY_ROLE
     * -id: has not been minted before & within the 5 prelisted tokens
     * 
     *@dev minted tokens are held by QuestProperties contract.
     */
    function mintNFT(
        uint256 id,
        bytes memory data,
        uint256 price
    )
        external
        payable
        virtual
        onlyRole(TREASURY_ROLE)
        returns (uint256, uint256)
    {
        require(
            !exists(id) && id <= availableTokens.length,
            "Quest: token already minted or out of range"
        );
        //waiting for John's list of rights with zero value
        _mint(address(this), id, 1, data);

        properties[propertyId].tokens.push(Token({id: id, price: price, timeStamp: block.timestamp}));

        return (id, price);
    }

    /**
     *@param ids uint, token ids
     *@param amounts uint. amounts of token ids to mint
     *@param data bytes, ipfs generated hash 
     *@param prices uint, tokens' prices in USDC/Quest Coin
     *
     *Requirements:
     *
     * -TREASURY_ROLE
     * -tokens ids, amounts, & prices have the same length
     * -tokens ids have not minted before and within the prespecified range.
     *
     *@dev minted tokens are minted to this contract 
     */
    function mintBatchNFTs(
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        uint256[] memory prices
    )
        external
        payable
        virtual
        onlyRole(TREASURY_ROLE)
        returns (uint256[] memory, uint256[] memory)
    {
        require(
            ids.length == prices.length && ids.length == prices.length,
            "Quest: ids, amounts, & prices length mismatch"
        );

        uint256 j = 0;
        uint256 len = ids.length;
        for (j = 0; j <= len; j++) {

            properties[ids[j]].tokens.push(Token({id:ids[j], price:prices[j], timeStamp: block.timestamp}));
        }

        require(!exists(ids[j]) && ids[j] <= availableTokens.length, "Quest: token is minted or out of range");
      
        _mintBatch(address(this), ids, amounts, data);

        return (ids, prices);
    }

    /**
     *@dev Burn token `id` with amount `amount` from `from`
     *
     *Requirements: 
     * - Only DEFAULT_ADMIN_ROLE which is msg.sender
     * - caller is the owner or approved operator
     * - token id exists, have been minted before
     */
    function burnNFT(address from, uint256 id, uint256 amount) external virtual onlyRole(TREASURY_ROLE) {
        require(exists(id), "Quest: NFT does not exist");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "Quest: caller is not owner nor approved"
        );
        _burn(from, id, amount);
    }

    /**
     *@dev Burn Btach of token `ids` from `from` of amounts `amounts`
     *
     * Requirements: 
     * - Only DEFAULT_ADMIN_ROLE which is msg.sender
     * - caller is the owner of approved operator
     */
    function burnBatchNFTs(address from, uint256[] memory ids, uint256[] memory amounts) external virtual onlyRole(TREASURY_ROLE) {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "Quest: caller is not owner nor approved"
        );
        _burnBatch(from, ids, amounts);
    }

    /**
     *@dev Transfers minted tokens and held by this contract to EOA or another contract
     *
     *Requirements:
     * - Only DEFAULT_ADMIN_ROLE
     * - This contract's balance of token id must be equal to or more than amount
     * - transfer to shouldn't be to zero address
     * - caller must be owner or approved operator to `safeTransferFrom`
     */
    function transferNFT(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external payable onlyRole(CONTRACT_ADMIN_ROLE) {
        require(balanceOf(address(this), id) >= amount, 'Quest: balance is not enought');
        require(to != address(0), "Quest: transfer to zero address");
        safeTransferFrom(address(this), to, id, amount, data);
    }

    /**
     *@dev  Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     *Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     *
     *Requirements:
     * - Only DEFAULT_ADMIN_ROLE
     */
    function setURI(string memory newuri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    /**
     *@dev Defining upgradeTo function in UUPS 
     * see: https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/UUPSUpgradeable.sol
     * 
     *Requirements:
     * - only UPGRADER_ROLE
     * - new Implemetation is a contract
     */
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyRole(UPGRADER_ROLE){
        require(
            AddressUpgradeable.isContract(newImplementation),
            "Quest: new Implementation must be a contract"
        );
    }

    //Increase supply in case of minting and decrease it in case of burning
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }
}