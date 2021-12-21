// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

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

    string public contractName;
    string public description;
    uint256 private propertyId;
    uint8 private currentVersion;

    struct Token {
        uint256 id;
        uint256 price;
    }

    struct Property {
        bytes parentHash;
        address propAddress;
        Token[] tokens;
    }

    mapping(uint256 => Property) private properties;
    mapping(uint256 => uint256) private _totalSupply;

    event PropertyAdded(uint256 propertyId, address property, bytes MerkleTree);

    uint256 public constant TITLE = 0;
    uint256 public constant GOVERNANCE_RIGHT = 1;
    uint256 public constant EQUITY_RIGHT = 2;
    uint256 public constant POSSESSION_RIGHT = 3;
    uint256 public constant RENT_RIGHT = 4;
    uint256 public constant MGMT_RIGHT = 5;

    uint256 public noOfRights;

    function initialize(
        address treasury,
        address upgrader,
        string memory uri,
        uint256 _noOfRights
    ) external virtual initializer {
        __ERC1155_init(uri);
        __AccessControl_init();
        __ERC1155Receiver_init();
        __ERC1155Holder_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(TREASURY_ROLE, treasury);
        _setupRole(UPGRADER_ROLE, upgrader);

        noOfRights = _noOfRights;
    }

    function approvedProperty(
        bytes memory _parentHash,
        address _propAddress,
        string memory _contractName,
        string memory _description
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        propertyIds.increment();
        propertyId = propertyIds.current();
        properties[propertyId].parentHash = _parentHash;
        properties[propertyId].propAddress = _propAddress;

        contractName = _contractName;
        description = _description;

        emit PropertyAdded(propertyId, _propAddress, _parentHash);
    }

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

    function getPropertyId() public view returns (uint256) {
        return propertyId;
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return QuestProperties.totalSupply(id) > 0;
    }

    function version() public pure virtual returns (string memory) {
        return "1.0.0";
    }

    function upgradeTo(address newImplementation) external virtual override {
        require(
            AddressUpgradeable.isContract(newImplementation),
            "Quest: new Implementation must be a contract"
        );
    }

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
        require(!exists(id), "Quest: token already minted");
        require(id <= noOfRights, "Quest: invalid token id");
        //We just need to check if the price of the token is greater than 0, the else statement is not required, please comment your thoughts on this
        if (price == 0) {
            id = 0;
        }
        _mint(address(this), id, 1, data);
        properties[propertyId].tokens.push(Token(id, price));

        return (id, price);
    }

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
        returns (uint256[] memory _ids, uint256[] memory _prices)
    {
        require(
            ids.length == prices.length,
            "Quest: ids and prices length mismatch"
        );
        _mintBatch(address(this), ids, amounts, data);
        uint256 j = 0;
        uint256 len = ids.length;
        for (j = 0; j <= len; j++) {
            require(!exists(ids[j]), "Quest: token already minted");
            require(ids[j] <= noOfRights, "Quest: invalid token id");
            properties[ids[j]].tokens.push(Token(ids[j], prices[j]));
        }
        //returns two arrays, one with the ids and one with the prices
        return (ids, prices);
    }

    function burnNFT(
        address from,
        uint256 id,
        uint256 amount
    ) external virtual onlyRole(TREASURY_ROLE) {
        require(exists(id), "Quest: NFT does not exist");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "Quest: caller is not owner nor approved"
        );
        _burn(from, id, amount);
    }

    function burnBatchNFTs(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external virtual onlyRole(TREASURY_ROLE) {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "Quest: caller is not owner nor approved"
        );
        _burnBatch(from, ids, amounts);
    }

    function transferNFT(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        require(balanceOf(address(this), id) >= amount);
        require(to != address(0), "Quest: transfer to zero address");
        safeTransferFrom(address(this), to, id, amount, data);
    }

    function setURI(string memory newuri)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setURI(newuri);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyRole(UPGRADER_ROLE)
    {}

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
