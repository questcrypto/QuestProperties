// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';


contract QuestProperties is Initializable, ERC1155Upgradeable, ERC1155HolderUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter propertyIds;
    CountersUpgradeable.Counter verisons;


    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    string public contractName;
    string public description;
    uint256 private propertyId;
    uint256 private currentVersion;


    struct Token{
        uint256 id;
        uint256 price;
    }

    struct Property{
        bytes parentHash;
        address propAddress;
        Token[] tokens;
    }

    uint256[5] public availableTokens;


    
    mapping(uint256 => Property) private properties;
    mapping(uint256 => uint256) private _totalSupply;
    mapping(string=>bool) private propertyExists;


    event PropertyAdded(uint256 propertyId, address property, bytes MerkleTree);

    uint256 public constant TITLE = 0;
    uint256 public constant GOVERNANCE_RIGHT = 1;
    uint256 public constant EQUITY_RIGHT = 2;
    uint256 public constant POSSESSION_RIGHT = 3;
    uint256 public constant RENT_RIGHT = 4;
    uint256 public constant MGMT_RIGHT = 5;

    
    function initialize(
        address treasury, 
        address upgrader, 
        string memory uri,
        string memory _contractName, 
        string memory _description
        ) external virtual initializer {
        
        __ERC1155_init(uri);
        __AccessControl_init();
        __ERC1155Receiver_init();
        __ERC1155Holder_init();
        __UUPSUpgradeable_init();
       
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(TREASURY_ROLE, treasury);
        _setupRole(UPGRADER_ROLE, upgrader);

        contractName = _contractName;
        description = _description;

        propertyIds.increment();
        propertyId= propertyIds.current();

        propertyExists[uri] = true;
    }

    function approvedProperty(bytes memory _parentHash, address _propAddress) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        properties[propertyId].parentHash = _parentHash;
        properties[propertyId].propAddress = _propAddress;

        emit PropertyAdded(propertyId, _propAddress, _parentHash);   
    }

    //@Arhan: cooperate with FE to support Interfaces
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getPropertyId() public view returns(uint256)  {
        return propertyId;
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return QuestProperties.totalSupply(id) > 0;
    }

    function version() public virtual returns(uint256) {
        verisons.increment();
        currentVersion = verisons.current();
        
        return currentVersion;
    }
    //@sasha:look again
    function upgradeTo(address newImplementation) external virtual override {
        require(AddressUpgradeable.isContract(newImplementation), 'Quest: new Implementation must be a contract');
      
    }


    function mintNFT (uint256 id, bytes memory data, uint256 price) external virtual payable onlyRole(TREASURY_ROLE) returns(uint256, uint256) {
        require(!exists(id), "Quest: token already minted");
        require(id <= availableTokens.length, 'Quest: minting id is out of range.');
        //waiting for John's list of rights with zero value
        _mint(address(this), id, 1, data);
        properties[propertyId].tokens.push(Token(id,price));
        
        return (id,price);
    }

    function mintBatchNFTs (
        uint256[] memory ids, 
        uint256[] memory amounts, 
        bytes memory data, 
        uint256[] memory prices
        ) external 
        virtual 
        payable 
        onlyRole(TREASURY_ROLE) 
        returns(uint256[] memory, uint256[] memory) {
        
        require(ids.length == prices.length, 'Quest: ids, prices, data length mismatch');

        uint j = 0;
        uint len = ids.length;
        for (j = 0; j <= len; j++) { 
        properties[ids[j]].tokens.push(Token(ids[j],prices[j]));
        }

        require(!exists(ids[j]), 'Quest: token is minted');
        require(ids[j] <= availableTokens.length, 'Quest: tokens are not available');

        _mintBatch(address(this), ids, amounts, data);
        
        return(ids,prices); 
    }
        

    function burnNFT(address from, uint256 id, uint256 amount) external virtual onlyRole(DEFAULT_ADMIN_ROLE){
        require(exists(id), 'Quest: NFT does not exist');
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "Quest: caller is not owner nor approved");
        _burn(from, id, amount);
    }

    function burnBatchNFTs(address from, uint256[] memory ids, uint256[] memory amounts) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "Quest: caller is not owner nor approved");
        _burnBatch(from, ids, amounts);
    }
    
    function transferNFT(address to, uint256 id, uint256 amount, bytes memory data) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        require(balanceOf(address(this), id) >= amount);
        require(to != address(0), "Quest: transfer to zero address");
        safeTransferFrom(address(this), to, id, amount, data);
    }


    function setURI(string memory newuri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    //@Sasha: need to improve and ensure right execution
    function _authorizeUpgrade(address newImplementation) internal virtual  override onlyRole(UPGRADER_ROLE) {}


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




