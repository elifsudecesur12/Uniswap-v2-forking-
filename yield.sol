// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



IERC20 public yieldToken; 
IERC20 public stakingToken; 
uint256 public totalStaked; 
uint256 public rewardPerToken; 
mapping(address => uint256) public stakedBalance; 
mapping(address => uint256) public rewards; 

function stake(uint256 amount) external {
    require(amount > 0, 'Amount must be greater than 0');
   
    stakingToken.transferFrom(msg.sender, address(this), amount);

  
    uint256 pendingRewards = calculateRewards(msg.sender);
    rewards[msg.sender] += pendingRewards;

    stakedBalance[msg.sender] += amount;
    totalStaked += amount;
}
function unstake(uint256 amount) external {
    require(amount > 0, 'Amount must be greater than 0');
    require(stakedBalance[msg.sender] >= amount, 'Not enough staked');

    
    uint256 pendingRewards = calculateRewards(msg.sender);
    rewards[msg.sender] += pendingRewards;

    stakingToken.transfer(msg.sender, amount);

    stakedBalance[msg.sender] -= amount;
    totalStaked -= amount;
}
function calculateRewards(address user) internal view returns (uint256) {
    uint256 stakedAmount = stakedBalance[user];
    uint256 pendingRewards = (stakedAmount * (rewardPerToken - rewards[user])) / 1e18;
    return pendingRewards;
}
function harvest() external {
    uint256 pendingRewards = calculateRewards(msg.sender);
    rewards[msg.sender] += pendingRewards;
  
    yieldToken.transfer(msg.sender, pendingRewards);
}



