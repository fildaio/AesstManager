// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./DistributionRecipient.sol";
import "./dependence.sol";

contract TokenDistributor is DistributionRecipient {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct RecipientEntity {
        uint256 proportion;
        uint256 index;
    }

    mapping (address => RecipientEntity) recipientEntities;
    address[] public recipientList;

    IERC20 public token;
    uint256 public lastUpdateHeight;
    uint256[] public rewardHeightArray;
    uint256[] public rewardPerBlockArray;

    function initialize(address _distribution,
        address _token,
        uint256[] memory _rewardHeightArray,
        uint256[] memory _rewardPerBlockArray) public initializer {
        require(_token != address(0) && _rewardHeightArray.length == _rewardPerBlockArray.length, "please check parameters");

        DistributionRecipient.initialize(_distribution);
        token = IERC20(_token);
        lastUpdateHeight = _rewardHeightArray[0];
        rewardHeightArray = _rewardHeightArray;
        rewardPerBlockArray = _rewardPerBlockArray;
    }

    function exist(address recipient) public view returns (bool) {
        if(recipientList.length == 0 || recipientEntities[recipient].index >= recipientList.length) return false;
        return (recipientList[recipientEntities[recipient].index] == recipient);
    }

    function add(address[] memory recipient, uint256[] memory proportion) public onlyOwner {
        for (uint i = 0; i < recipient.length; i++) {
            require(recipient[i] != address(0), "recipient is zero address");
            if (exist(recipient[i])) continue;
            uint256 index = recipientList.push(recipient[i]) - 1;
            recipientEntities[recipient[i]].proportion = proportion[i];
            recipientEntities[recipient[i]].index = index;
        }

    }

    function getRecipientCount() public view returns (uint256) {
        return recipientList.length;
    }

    function getProportion(address recipient) public view returns (uint256) {
        if(!exist(recipient)) return 0;
        return recipientEntities[recipient].proportion;
    }

    function updateProportion(address recipient, uint256 proportion) public onlyOwner {
        require(exist(recipient), "not registered");
        recipientEntities[recipient].proportion = proportion;
    }

    function remove(address recipient) external onlyOwner returns (uint256) {
        require(exist(recipient), "not exist");
        if (recipientList.length == 1) {
            recipientList.length--;
            return 0;
        }
        uint256 rowToDelete = recipientEntities[recipient].index;
        address keyToMove = recipientList[recipientList.length-1];
        recipientList[rowToDelete] = keyToMove;
        recipientEntities[keyToMove].index = rowToDelete;
        recipientList.length--;
        return rowToDelete;
    }

    function withdraw(address _token, address _account, uint256 amount) external onlyOwner returns (uint) {
        IERC20 itoken = IERC20(_token);
        if (amount > itoken.balanceOf(address(this))) {
            amount = itoken.balanceOf(address(this));
        }
        itoken.safeTransfer(_account, amount);
        return amount;
    }

    function setReward(uint256[] calldata _rewardHeightArray, uint256[] calldata _rewardPerBlockArray) external onlyOwner {
        require(_rewardHeightArray.length == _rewardPerBlockArray.length, "please check parameters");
        rewardHeightArray = _rewardHeightArray;
        rewardPerBlockArray = _rewardPerBlockArray;
    }


    function pushToken() external onlyRewardDistribution {
        require(block.number > lastUpdateHeight && recipientList.length > 0, "not start");

        uint last = findIndex(lastUpdateHeight);
        uint current = findIndex(block.number);
        uint256 totalAmount = 0;

        while (last <= current) {
            if (last == current) {
                totalAmount = totalAmount.add(block.number.sub(lastUpdateHeight).mul(rewardPerBlockArray[last]));
            } else {
                totalAmount = totalAmount.add(rewardHeightArray[last + 1].sub(lastUpdateHeight).mul(rewardPerBlockArray[last]));
                lastUpdateHeight = rewardHeightArray[last + 1];
            }

            last++;
        }

        if (totalAmount > 0) {
            for (uint i = 0; i < recipientList.length; i++) {
                token.safeTransfer(recipientList[i], recipientEntities[recipientList[i]].proportion.mul(totalAmount).div(1e18));
            }
        }

        lastUpdateHeight = block.number;
    }

    function findIndex(uint256 blockNumber) internal view returns(uint256) {
        for (uint i = 0; i < rewardHeightArray.length; i++) {
            if (i != rewardHeightArray.length - 1
                && blockNumber >= rewardHeightArray[i]
                && blockNumber < rewardHeightArray[i+1]) {
                return i;
            } else if (i == rewardHeightArray.length - 1 && blockNumber >= rewardHeightArray[i]) {
                return i;
            }
        }
    }
}
