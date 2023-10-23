// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPool is Ownable {
    IERC20 public token1;
    IERC20 public token2;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    
    constructor(address _token1, address _token2) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function deposit(uint256 amount1, uint256 amount2) external {
        require(amount1 > 0, "Amount1 must be greater than 0");
        require(amount2 > 0, "Amount2 must be greater than 0");
        
        require(token1.transferFrom(msg.sender, address(this), amount1), "Transfer of token1 failed");
        require(token2.transferFrom(msg.sender, address(this), amount2), "Transfer of token2 failed");
        
        uint256 liquidity = calculateLiquidity(amount1, amount2);
        totalSupply += liquidity;
        balances[msg.sender] += liquidity;
    }

    function withdraw(uint256 liquidity) external {
        require(liquidity > 0, "Liquidity must be greater than 0");
        require(balances[msg.sender] >= liquidity, "Insufficient liquidity balance");
        
        uint256 amount1 = (liquidity * token1.balanceOf(address(this))) / totalSupply;
        uint256 amount2 = (liquidity * token2.balanceOf(address(this))) / totalSupply;
        
        require(token1.transfer(msg.sender, amount1), "Transfer of token1 failed");
        require(token2.transfer(msg.sender, amount2), "Transfer of token2 failed");
        
        totalSupply -= liquidity;
        balances[msg.sender] -= liquidity;
    }

    function calculateLiquidity(uint256 amount1, uint256 amount2) internal view returns (uint256) {
        uint256 balance1 = token1.balanceOf(address(this));
        uint256 balance2 = token2.balanceOf(address(this));
        return (totalSupply == 0)
            ? (amount1 * amount2)
            : (amount1 * totalSupply) / balance1;
    }
    
    function getReserves() external view returns (uint256 reserve1, uint256 reserve2) {
        return (token1.balanceOf(address(this)), token2.balanceOf(address(this)));
    }
}

