// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./DistributionRecipient.sol";

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
    uint256 public halfHeight;
    uint256 public constant rewardPerBlock = 1.25 * 1e18;
    uint256 public constant rewardHalfPerBlock = 0.6 * 1e18;

    function initialize(address _distribution, address _token, uint256 _startHeight, uint256 _halfHeight) public initializer {
        require(_token != address(0), "please check parameters");
        DistributionRecipient.initialize(_distribution);
        token = IERC20(_token);
        lastUpdateHeight = _startHeight;
        halfHeight = _halfHeight;
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

    function setHalfHeight(uint256 height) external onlyOwner {
        halfHeight = height;
    }

    function pushToken() external onlyDistribution {
        require(block.number > lastUpdateHeight, "not start");

        for (uint i = 0; i < recipientList.length; i++) {
            uint256 amount = recipientEntities[recipientList[i]].proportion;
            if (halfHeight >= block.number) {
                amount = amount.mul(block.number.sub(lastUpdateHeight).mul(rewardPerBlock)).div(1e18);
            } else if (block.number > halfHeight && lastUpdateHeight < halfHeight) {
                amount = amount.mul(block.number.sub(halfHeight).mul(rewardHalfPerBlock).add(halfHeight.sub(lastUpdateHeight).mul(rewardPerBlock))).div(1e18);
            } else {
                amount = amount.mul(block.number.sub(lastUpdateHeight).mul(rewardHalfPerBlock)).div(1e18);
            }

            token.safeTransfer(recipientList[i], amount);
        }

        lastUpdateHeight = block.number;
    }

}
