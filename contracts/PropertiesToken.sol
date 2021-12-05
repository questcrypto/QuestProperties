// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/presets/ERC1155PresetMinterPauserUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';

contract PropertiesToken is Initializable, ERC1155PresetMinterPauserUpgradeable, ERC1155HolderUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter propertyIds;


    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    string public contractName;
    string public description;
    uint256 private propertyId;

    struct Property{
        bytes parentHash;
        address propAddress;
        uint256 tokenId;
        uint256 tokenPrice;
    }


    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256=> Property) public properties;

    event PropertyAdded(uint256 propertyId, address property, bytes MerkleTree);

    function initialize(address treasury, address upgrader, string memory uri, string memory name, string memory describe) initializer public{
        __ERC1155PresetMinterPauser_init(uri);
        __ERC1155Receiver_init();
        __ERC1155Holder_init();
        __UUPSUpgradeable_init();
       
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(TREASURY_ROLE, treasury);
        _setupRole(UPGRADER_ROLE, upgrader);

        contractName = name;
        description = describe;
    }

    function approvedProperty(bytes memory _parentHash, address _propAddress) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        propertyIds.increment();
        propertyId= propertyIds.current();
        properties[propertyId].parentHash = _parentHash;
        properties[propertyId].propAddress = _propAddress;

        emit PropertyAdded(propertyId, _propAddress, _parentHash);
    }

    function pause() public virtual override {
        require(hasRole(TREASURY_ROLE, msg.sender), 'Quest: only TREASURY_ROLE');
        _pause();
    }

    function unpause() public virtual override {
        require(hasRole(TREASURY_ROLE, msg.sender), 'Quest: only TREASURY_ROLE');
        _unpause();
    }

    function getPropertyId() public view returns(uint256)  {
        return propertyId;
    }

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return PropertiesToken.totalSupply(id) > 0;
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155PresetMinterPauserUpgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}


}




