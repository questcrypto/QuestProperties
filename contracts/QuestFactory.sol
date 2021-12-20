// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./QuestProperties.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol';
import '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol'; //make sure if init is needed


contract QuestFactory is Initializable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {

  address immutable logicAddress;

  
  event TokenDeployed(address tokenAddress);

  function initialize() public virtual initializer whenNotPaused {
    __UUPSUpgradeable_init();
    __Pausable_init();
    __Ownable_init(); //HOA = msg.sender

    logicAddress = address(new QuestProperties());
  }

  function listProperty(address treasury, address upgrader, string calldata uri) public virtual whenNotPaused returns(address) {
    ERC1967Proxy proxy= new ERC1967Proxy(
      logicAddress,
      abi.encodeWithSignature(QuestProperties(address(0)).initialize.selector, treasury, upgrader, uri)
    );

    emit TokenDeployed(address( proxy));

    return address(proxy);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
        _unpause();
  }

  function upgradeTo(address newFactory) external virtual override {
    _authorizeUpgrade(newFactory);
    _upgradeToAndCallSecure(newFactory, new bytes(0), false);
    require (AddressUpgradeable.isContract(newFactory), 'Quest: new Implementation must be a contract');
  }
  

  function _authorizeUpgrade(address newFactory) internal virtual  override onlyOwner {}

}
