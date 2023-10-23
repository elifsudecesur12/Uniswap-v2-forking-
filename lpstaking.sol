// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPStakingContract is Ownable {
    IERC20 public lpToken; // LP Token (Liquidity Pool Token)
    IERC20 public rewardToken; // Ödül Token
    uint256 public stakingDuration; // Staking süresi (saniye cinsinden)
    uint256 public rewardPerSecond; // Saniyede verilen ödül miktarı

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingStartTime;

    constructor(
        address _lpToken,
        address _rewardToken,
        uint256 _stakingDuration,
        uint256 _rewardPerSecond
    ) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
        stakingDuration = _stakingDuration;
        rewardPerSecond = _rewardPerSecond;
    }

    function stakeLP(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(lpToken.transferFrom(msg.sender, address(this), amount), "Transfer of LP tokens failed");

        stakedBalance[msg.sender] += amount;
        stakingStartTime[msg.sender] = block.timestamp;
    }

    function withdrawStake() external {
        require(stakedBalance[msg.sender] > 0, "No stake to withdraw");
        require(block.timestamp >= stakingStartTime[msg.sender] + stakingDuration, "Staking duration not completed yet");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = stakedBalance[msg.sender] + reward;

        stakedBalance[msg.sender] = 0;
        stakingStartTime[msg.sender] = 0;

        require(lpToken.transfer(msg.sender, totalAmount), "Transfer of LP tokens failed");
    }

    function calculateReward(address staker) public view returns (uint256) {
        if (block.timestamp < stakingStartTime[staker] + stakingDuration) {
            return 0;
        }

        uint256 stakingTime = block.timestamp - stakingStartTime[staker];
        return (stakingTime * rewardPerSecond);
    }
}
