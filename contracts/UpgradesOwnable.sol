pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * modify from openzeppelin/upgrades/contracts/ownership/Ownable.sol
 */

contract UpgradesOwnable is Initializable {
    bytes32 internal constant _OWNER_SLOT = bytes32(uint256(keccak256("filda.upgradesownable.slot")) - 1);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable initilize sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize() internal initializer {
        _setOwner(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address str) {
        bytes32 slot = _OWNER_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            str := sload(slot)
        }
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "UpgradesOwnable: Caller is not owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner();
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner(), address(0));
        _setOwner(address(0));
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner(), newOwner);
        _setOwner(newOwner);
    }

    function _setOwner(address _owner) private {
        bytes32 slot = _OWNER_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, _owner)
        }
    }
}
