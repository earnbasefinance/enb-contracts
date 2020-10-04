pragma solidity ^0.5.16;

// Inheritance
import "@openzeppelin/contracts/Ownership/Ownable.sol";

// https://docs.synthetix.io/contracts/RewardsDistributionRecipient
contract RewardsDistributionRecipient is Ownable {
    address public rewardsDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}