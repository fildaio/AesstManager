// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@openzeppelin/upgrades/contracts/upgradeability/BaseUpgradeabilityProxy.sol";
import "./GovernableInitiable.sol";

contract HandlerProxy is BaseUpgradeabilityProxy, GovernableInitiable {

  constructor(address _implementation, address _governance) public GovernableInitiable(_governance) {
    _setImplementation(_implementation);
  }

  function upgrade(address newImplementation) external onlyGovernance {
    _upgradeTo(newImplementation);
  }

  function implementation() external view returns (address) {
    return _implementation();
  }
}

