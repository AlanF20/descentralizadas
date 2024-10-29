// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./SimpleCoin.sol";

contract SimpleCrowdSale {
    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiTokenPrice;
    uint256 public weiInvestmentObjective;
    mapping(address => uint256) public investmentAmountOf;
    uint256 public investmentReceived;
    uint256 public investRefunded;
    bool public isFinalized;
    bool public isRefundedAllowed;
    address public owner;
    SimpleCoin public crowdSaleToken;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    event LogNewInvestment(address indexed investor, uint256 value);
    event LogTokenMinting(address indexed beneficiary, uint256 numberOfTokens);
    event LogCrowdsaleFinalized();
    event LogRefundAllowed();
    event LogRefundIssued(address indexed investor, uint256 value);

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _weiTokenPrice,
        uint256 _etherInvestmentObjective
    ) {
        require(_startTime >= block.timestamp, "Start time should be in the future.");
        require(_endTime >= _startTime, "End time should be after start time.");
        require(_weiTokenPrice != 0, "Token price should be non-zero.");
        require(_etherInvestmentObjective != 0, "Investment objective should be non-zero.");

        startTime = _startTime;
        endTime = _endTime;
        weiTokenPrice = _weiTokenPrice;
        weiInvestmentObjective = _etherInvestmentObjective * 1 ether;
        crowdSaleToken = new SimpleCoin(0);
        isFinalized = false;
        isRefundedAllowed = false;
        owner = msg.sender;
    }

    function isValidInvestment(uint256 _investment) internal view returns (bool) {
        bool nonZeroInvestment = _investment != 0;
        bool withinCrowdSalePeriod = block.timestamp >= startTime && block.timestamp <= endTime;
        return nonZeroInvestment && withinCrowdSalePeriod;
    }

    function calculateNumberOfTokens(uint256 _investment) internal view returns (uint256) {
        return _investment / weiTokenPrice;
    }

    function assignTokens(address _beneficiary, uint256 _investment) internal {
        uint256 numberOfTokens = calculateNumberOfTokens(_investment);
        crowdSaleToken.mint(_beneficiary, numberOfTokens);
        emit LogTokenMinting(_beneficiary, numberOfTokens);
    }

    function invest(address _beneficiary) public payable {
        require(isValidInvestment(msg.value), "Invalid investment.");
        address investor = msg.sender;
        uint256 investment = msg.value;

        investmentAmountOf[investor] += investment;
        investmentReceived += investment;

        assignTokens(_beneficiary, investment);

        emit LogNewInvestment(investor, investment);
    }

    function finalize() public onlyOwner {
        require(!isFinalized, "Crowdsale already finalized.");
        bool isCrowdSaleComplete = block.timestamp > endTime;
        bool investmentObjectiveMet = investmentReceived >= weiInvestmentObjective;

        if (isCrowdSaleComplete) {
            if (investmentObjectiveMet) {
                crowdSaleToken.release();
            } else {
                isRefundedAllowed = true;
                emit LogRefundAllowed();
            }
            isFinalized = true;
            emit LogCrowdsaleFinalized();
        }
    }

    function refund() public {
        require(isRefundedAllowed, "Refunds not allowed.");
        address payable investor = payable(msg.sender);
        uint256 investment = investmentAmountOf[investor];
        require(investment > 0, "No investment to refund.");

        investmentAmountOf[investor] = 0;
        investRefunded += investment;

        emit LogRefundIssued(investor, investment);
        investor.transfer(investment);
    }
}
