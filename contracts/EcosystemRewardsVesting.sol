pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract EcosystemRewardsVesting {
    using SafeMath for uint256;

    ERC20 public token = ERC20(0xa6FB1DF483b24EEAB569e19447E0e107003B9E15);

    address public recipient = 0xed0c81eE00753B37FD4Ce3094827019A02bC8A28;
    uint256 private firstRelease = 1605052800; // first release
    uint256 private claimedReleases = 0;
    uint256 public releaseInterval = 30 days;
    uint256 public percentagePerRelease = 4;

    uint256 public paidAmount;

    modifier onlyRecipient () {
        require(msg.sender == recipient, "NOT_RECIPIENT");
        _;
    }

    function claim() public onlyRecipient {
        uint256 claimingAmount = claimableAmount();
        token.transfer(recipient, claimingAmount);
        paidAmount = paidAmount.add(claimingAmount);

        uint256 amount;
        uint256 releases;
        (amount, releases) = claimableAmountAndReleases();

        claimedReleases += releases;
    }

    function claimableAmount() public view returns(uint256) {
        if (!isVestingStarted()) 
            return 0;
        
        uint256 amount;
        (amount,) = claimableAmountAndReleases();
        return amount;
    }

    function claimableAmountAndReleases() internal view returns(uint256, uint256) {
        uint256 elapsedTime = block.timestamp.sub(firstRelease);
        uint256 claimableReleases = elapsedTime.div(releaseInterval) + 1 - claimedReleases;
        uint256 i;
        uint256 balance = token.balanceOf(address(this));
        uint256 amount = 0;

        for (i = 0; i < claimableReleases; i ++) {
            amount = amount.add(balance.sub(amount).mul(percentagePerRelease).div(100));
        }
        return (amount, claimableReleases);
    }

    function pastReleaseCount() public view returns(uint256) {
        if (firstRelease > block.timestamp)
            return 0;
        uint256 elapsedTime = block.timestamp.sub(firstRelease);
        return elapsedTime.div(releaseInterval) + 1;
    }

    function nextReleaseTimestamp() public view returns(uint256) {
        if (!isVestingStarted()) {
            return firstRelease;
        }
        uint256 releasedCount = pastReleaseCount();

        return firstRelease.add(releaseInterval.mul(releasedCount));
    }

    function isVestingStarted() public view returns(bool) {
        return firstRelease <= block.timestamp;
    }
}
