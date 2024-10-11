// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./SimpleCoin.sol";

contract SimpleCrowdSale {
    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiTokenPrice;
    uint256 public weiInvestmentObjective;
    mapping(address => uint256) public investmentAmountOf;
    //Cumulo de inversiones recibido a traves del contrato
    uint256 public investmenteReceived;
    //Cantidad de dinero retornado
    uint256 public investRefunded;
    //Bandera si el crowd sale termino
    bool public isFinalized;
    //Bandera para determinar si esta permitido retornar el valor
    bool public isRefundedAllowed;
    //Direccion del dueño
    address public owner;
    //Token
    SimpleCoin public crowdSaleToken;
   
    modifier onlyOwner(){
      if(msg.sender != owner) revert();
      _;
    }

    constructor(
      uint256 _startTime,
      uint256 _endTime,
      uint256 _weiTokenPrice,
      uint256 _etherInvestmentObjective
    )public{
      require(_startTime >= block.timestamp);
      require(_endTime >= _startTime);
      require(_weiTokenPrice != 0);
      require(_etherInvestmentObjective != 0);
      startTime = _startTime;
      weiTokenPrice=_weiTokenPrice;
      weiInvestmentObjective = _etherInvestmentObjective * 1000000000000000000;
      crowdSaleToken = new SimpleCoin(0);
      isFinalized = false;
      isRefundedAllowed = false;
      owner = msg.sender;
    }

    function isValidInvestment(uint256 _investment)internal view returns(bool){
      bool nonZeroInvestment = _investment != 0;
      bool withinCrowdSalePeriod = block.timestamp >= startTime && block.timestamp <= endTime;
      return nonZeroInvestment && withinCrowdSalePeriod
    }

    function CalculateNumberOfTokens(uint256 _investment)internal returns (uint256){
      return _investment / weiTokenPrice;
    }

    function AssignTokens(address _beneficiary, uint256 _investment)internal{
      uint256 _numberofTokens = CalculateNumberOfTokens(_investment);
      crowdSaleToken.mint(_beneficiary, _numberofTokens);
    }

    event LogInvestment(address indexed investor, uint256 value);
    event LogTokenAssignment(address indexed investor, uint256 numTokens);

    function Invest(address _beneficiary) public payable{
      require(isValidInvestment(msg.value));
      address investor = msg.sender;
      uint256 investment = msg.value;
      investmentAmountOf[investor] += investment;
      investmentReceived += investment;
      AssignTokens(investor, investment);
      emit LogInvestment(investor, investment);
    }

    function Finalize()public onlyOwner{
      if(isFinalized) revert();
      bool isCrowdSaleComplete = block.timestamp > endTime;
      bool investmentObjective = investmentReceived >= weiInvestmentObjective;

      if(isCrowdSaleComplete){
        if(investmentObjective){
          crowdSaleToken.release();
        }else{
          isRefundedAllowed = true;
        }
        isFinalized = true;
      }
    }

    event Refund(address investor, uint256 value);
    function refund() public{
      if(!isRefundedAllowed) revert();
      // payable funciona para decir que una direccion puede recibir ethereum
      address payable investor = payable(msg.sender);
      uint256 investment = investmentAmountOf[investor];
      if(investment == 0) revert();
      investmentAmountOf[investor] = 0;
      investRefunded += investment;
      emit Refund(msg.sender, investment);
      if(!investor.send(investment)) revert(); 
    }
}
