// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;

import './SimpleCoin.sol';

contract SimpleCrowdSale{
  uint256 public startTime;
  uint256 public endTime;
  uint256 public weiTokenPrice;
  uint256 public weiInvestmentObjective;
  mapping(address => uint256) public investmentAmountOf;
  uint256 public investmenteReceived;
  uint256 public investRefunded;
  bool public isFinalized;
  bool public isRefundedAllowed;
  address public owner;
  SimpleCoin public crowdSaleToken;
}