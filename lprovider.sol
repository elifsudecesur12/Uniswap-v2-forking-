// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPStaking is Ownable {
    IERC20 public lpToken; // LP token adresi
    IERC20 public rewardToken; // Ödül token adresi
    uint256 public totalStaked;
    uint256 public rewardRate; // Ödül oranı (örneğin, 1000 = 0.1, 10000 = 1)
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public rewards;

    constructor(
        address _lpToken,
        address _rewardToken,
        uint256 _rewardRate
    ) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        updateReward(msg.sender);
        lpToken.transferFrom(msg.sender, address(this), amount);
        userStaked[msg.sender] += amount;
        totalStaked += amount;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(userStaked[msg.sender] >= amount, "Insufficient staked amount");
        updateReward(msg.sender);
        lpToken.transfer(msg.sender, amount);
        userStaked[msg.sender] -= amount;
        totalStaked -= amount;
    }

    function getReward() external {
        updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
    }

    function exit() external {
        uint256 stakedAmount = userStaked[msg.sender];
        if (stakedAmount > 0) {
            withdraw(stakedAmount);
            getReward();
        }
    }

    function updateReward(address account) internal {
        uint256 lpBalance = userStaked[account];
        if (lpBalance > 0) {
            uint256 rewardPerToken = rewardPerToken();
            rewards[account] += (rewardPerToken - rewardPerTokenStored) * lpBalance / 1e18;
            rewardPerTokenStored = rewardPerToken;
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((block.timestamp - block.timestamp) * rewardRate * 1e18) / totalStaked;
    }

   
    function setRewardRate(uint256 newRate) external onlyOwner {
        rewardRate = newRate;
    }

   
    function withdrawRewardToken(uint256 amount) external onlyOwner {
        rewardToken.transfer(owner(), amount);
    }
}
