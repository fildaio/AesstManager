// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@openzeppelin/upgrades/contracts/upgradeability/BaseUpgradeabilityProxy.sol";
import "@openzeppelin/upgrades/contracts/ownership/Ownable.sol";

contract HandlerProxy is BaseUpgradeabilityProxy, OpenZeppelinUpgradesOwnable {

  constructor(address _implementation) public {
    _setImplementation(_implementation);
  }

  function upgrade(address newImplementation) external onlyOwner {
    _upgradeTo(newImplementation);
  }

  function implementation() external view returns (address) {
    return _implementation();
  }
}

