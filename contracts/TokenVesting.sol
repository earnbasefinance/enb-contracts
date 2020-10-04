pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract TokenVesting is Ownable{
    using SafeMath for uint256;
    using SafeMath for uint16;

    ERC20 public token;

    address public recipient;
    uint256 public totalAmount;
    uint256 private startTime = ~uint256(0);
    uint256 public releaseInterval;
    uint16 public totalReleaseCount;

    uint256 public paidAmount;

    modifier onlyRecipient () {
        require(msg.sender == recipient, "NOT_RECIPIENT");
        _;
    }

    constructor(ERC20 _token) public {
        require(address(_token) != address(0));
        token = _token;
    }

    function setVesting(address _recipient, uint256 _amount, uint256 _startTime, uint256 _releaseInterval, uint16 _releaseCount) external onlyOwner {
        require(startTime > block.timestamp, "VESTING_ALREADY_STARTED");
        require(_startTime > block.timestamp, "INVALID_START_TIME");
        require(_releaseCount > 0, "INVALID_RELEASE_COUNT");
        require(token.balanceOf(address(this)) >= _amount, "INSUFFICIENT_TOKEN_BALANCE");

        startTime = _startTime;
        releaseInterval = _releaseInterval;
        totalReleaseCount = _releaseCount;
        totalAmount = _amount;
        recipient = _recipient;
    }

    function cancelVesting() external onlyOwner {
        require(!isVestingStarted() , "VESTING_ALREADY_STARTED");

        token.transfer(owner(), token.balanceOf(address(this)));

        startTime = ~uint256(0);
        releaseInterval = 0;
        totalReleaseCount = 0;
        paidAmount = 0;
        recipient = address(0);
    }

    function claim() public onlyRecipient {
        uint256 claimingAmount = claimableAmount();
        token.transfer(recipient, claimingAmount);
        paidAmount = paidAmount.add(claimingAmount);
    }

    function claimableAmount() public view returns(uint256) {
        if (startTime > block.timestamp) 
            return 0;
        
        uint256 elapsedTime = block.timestamp.sub(startTime);
        // Check if all releases are gone
        uint256 totalApproved = amountPerRelease().mul(Math.min(elapsedTime.div(releaseInterval), totalReleaseCount));
        return totalApproved.sub(paidAmount);
    }
    
    function amountPerRelease() public view returns(uint256) {
        return totalAmount.div(totalReleaseCount);
    }

    function nextReleaseTimestamp() public view returns(uint256) {
        if (!isVestingSet()) {
            return 0;
        }

        if (!isVestingStarted()) {
            return startTime.add(releaseInterval);
        }

        uint256 elapsedTime = block.timestamp.sub(startTime);
        uint256 pastReleaseCount = elapsedTime.div(releaseInterval);

        if (pastReleaseCount > totalReleaseCount) {
            return 0;
        }
        return startTime.add(releaseInterval.mul(pastReleaseCount + 1));
    }

    function isVestingStarted() public view returns(bool) {
        return isVestingSet() && startTime <= block.timestamp;
    }

    function isVestingSet() public view returns(bool) {
        return totalReleaseCount > 0;
    }
}
