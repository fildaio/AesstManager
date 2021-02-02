// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./DistributionRecipient.sol";

interface NoMintRewardPool {
    function periodFinish() external returns (uint256);
    function rewardToken() external returns (address);
    function notifyRewardAmount(uint256 reward) external;
}

contract PoolHandler is DistributionRecipient {
    using SafeERC20 for IERC20;

    struct PoolEntity {
        uint256 rewardAmount;
        uint256 index;
    }

    mapping (address => PoolEntity) poolEntities;
    address[] public poolList;

    function initialize(address _distribution) public initializer {
        DistributionRecipient.initialize(_distribution);
    }

    function exist(address pool) public view returns (bool) {
        if(poolList.length == 0 || poolEntities[pool].index >= poolList.length) return false;
        return (poolList[poolEntities[pool].index] == pool);
    }

    function register(address pool, uint256 _rewardAmount) public onlyOwner returns (uint256) {
        require(!exist(pool), "aready exist!");
        uint256 index = poolList.push(pool) - 1;
        poolEntities[pool].rewardAmount = _rewardAmount;
        poolEntities[pool].index = index;
        return index;
    }

    function getPoolCounts() public view returns (uint256) {
        return poolList.length;
    }

    function rewardAmount(address pool) public view returns (uint256) {
        if(!exist(pool)) return 0;
        return poolEntities[pool].rewardAmount;
    }

    function updateAmount(address pool, uint256 _rewardAmount) public onlyOwner {
        require(exist(pool), "not registered");
        poolEntities[pool].rewardAmount = _rewardAmount;
    }

    function unregister(address pool) external onlyOwner returns (uint256) {
        require(exist(pool), "not exist");
        if (poolList.length == 1) {
            poolList.length--;
            return 0;
        }
        uint256 rowToDelete = poolEntities[pool].index;
        address keyToMove = poolList[poolList.length-1];
        poolList[rowToDelete] = keyToMove;
        poolEntities[keyToMove].index = rowToDelete;
        poolList.length--;
        return rowToDelete;
    }

    function notifyPoolStart(address poolAddr) external onlyDistribution {
        require(exist(poolAddr), "pool not exist!");
        NoMintRewardPool pool = NoMintRewardPool(poolAddr);
        require(block.timestamp > pool.periodFinish(), "pool not finished!");

        IERC20 token = IERC20(pool.rewardToken());
        token.safeTransfer(poolAddr, poolEntities[poolAddr].rewardAmount);
        pool.notifyRewardAmount(poolEntities[poolAddr].rewardAmount);
    }

    function withdraw(address _token, address _account, uint256 amount) external onlyOwner returns (uint) {
        IERC20 token = IERC20(_token);
        if (amount > token.balanceOf(address(this))) {
            amount = token.balanceOf(address(this));
        }
        token.safeTransfer(_account, amount);
        return amount;
    }

    function balanceOf(address _token) public view returns (uint) {
        return IERC20(_token).balanceOf(address(this));
    }

    function notifyPoolByBalance(address poolAddr) external onlyDistribution {
        require(exist(poolAddr), "pool not exist!");
        NoMintRewardPool pool = NoMintRewardPool(poolAddr);
        require(block.timestamp > pool.periodFinish(), "pool not finished!");

        address rewardToken = pool.rewardToken();
        uint256 balance = balanceOf(rewardToken);
        require(balance > 0, "balance is 0");

        IERC20 token = IERC20(rewardToken);
        token.safeTransfer(poolAddr, balance);
        pool.notifyRewardAmount(balance);
    }
}

