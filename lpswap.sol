// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPSwapContract is Ownable {
    IERC20 public lpToken; // LP Token (Liquidity Pool Token)
    IERC20 public tokenToSwap; // Takas yapılacak token
    uint256 public slippageTolerance; // Slippage toleransı (yüzde cinsinden)

    constructor(
        address _lpToken,
        address _tokenToSwap,
        uint256 _slippageTolerance
    ) {
        lpToken = IERC20(_lpToken);
        tokenToSwap = IERC20(_tokenToSwap);
        slippageTolerance = _slippageTolerance;
    }

    function swapLPTokens(uint256 lpAmount, uint256 minTokenToReceive) external {
        require(lpAmount > 0, "LP amount must be greater than 0");
        require(minTokenToReceive > 0, "Minimum token to receive must be greater than 0");

        uint256 lpBalance = lpToken.balanceOf(msg.sender);
        require(lpBalance >= lpAmount, "Insufficient LP token balance");

        uint256 tokenBalance = tokenToSwap.balanceOf(msg.sender);
        require(tokenBalance >= minTokenToReceive, "Insufficient token balance to receive");

        require(lpToken.transferFrom(msg.sender, address(this), lpAmount), "Transfer of LP tokens failed");

        uint256 tokenToReceive = calculateSwap(lpAmount);
        require(tokenToReceive >= minTokenToReceive, "Slippage tolerance exceeded");

        require(tokenToSwap.transfer(msg.sender, tokenToReceive), "Transfer of token failed");
    }

    function calculateSwap(uint256 lpAmount) public view returns (uint256) {
        uint256 lpBalance = lpToken.balanceOf(address(this));
        uint256 tokenToSwapBalance = tokenToSwap.balanceOf(address(this));

        uint256 tokenToReceive = (lpAmount * tokenToSwapBalance) / lpBalance;
        return tokenToReceive;
    }

    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOwner {
        require(_slippageTolerance <= 10, "Slippage tolerance cannot exceed 10%");
        slippageTolerance = _slippageTolerance;
    }
}
