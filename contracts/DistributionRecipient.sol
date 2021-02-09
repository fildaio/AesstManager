pragma solidity ^0.5.0;

import "./UpgradesOwnable.sol";

contract DistributionRecipient is UpgradesOwnable {
    bytes32 internal constant _REWARD_DISTRIBUTION_SLOT = bytes32(uint256(keccak256("filda.rewardDistribution.slot")) - 1);

    function initialize(address _rewardDistribution) public initializer {
        UpgradesOwnable.initialize();
        _setRewardDistribution(_rewardDistribution);
    }

    modifier onlyRewardDistribution() {
        require(msg.sender == rewardDistribution(), "Caller is not reward distribution");
        _;
    }

    function rewardDistribution() public view returns (address str) {
        bytes32 slot = _REWARD_DISTRIBUTION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            str := sload(slot)
        }
    }

    function _setRewardDistribution(address _rewardDistribution) private {
        bytes32 slot = _REWARD_DISTRIBUTION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, _rewardDistribution)
        }
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {
        _setRewardDistribution(_rewardDistribution);
    }
}
