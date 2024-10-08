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
}
