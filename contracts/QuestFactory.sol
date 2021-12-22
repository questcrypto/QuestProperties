// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./QuestProperties.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol';
import '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol'; 


contract QuestFactory is Initializable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
  

  address immutable logicAddress;
  address[] public proxies;

  event contractDeployed(address indexed propContractAddr);

  function initialize() public virtual initializer whenNotPaused {
    __UUPSUpgradeable_init();
    __Pausable_init();
    __Ownable_init(); //HOA = msg.sender
    

    logicAddress = address(new QuestProperties());
  }

  function deployPropertyContract(address treasury, address upgrader, string memory uri, string memory _contractName, string memory _description) public virtual whenNotPaused returns(address) {
    ERC1967Proxy proxy= new ERC1967Proxy(
      logicAddress,
      abi.encodeWithSignature(QuestProperties(address).initialize.selector, treasury, upgrader, uri, _contractName, _description)
    );

    emit  contractDeployed(address(proxy));

    proxies.push(address(proxy));

    return address(proxy);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }


  //@sasha: needs attention!
  function upgradeTo(address newFactory) external virtual override {
    _authorizeUpgrade(newFactory);
    _upgradeToAndCallSecure(newFactory, new bytes(0), false);
    require (AddressUpgradeable.isContract(newFactory), 'Quest: new factory must be a contract');
  }
  

  function _authorizeUpgrade(address newFactory) internal virtual  override onlyOwner {
    
  }

}
