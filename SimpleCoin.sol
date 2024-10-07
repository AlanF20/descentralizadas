// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;

contract SimpleCoin{
  address owner;
  mapping(address => uint256) public coinBalance;
  mapping(address => bool) public isFrozenAccount;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event FreezeAccount(address target, bool isFrozen);
  bool isReleased;

  constructor(uint256 _initialSupply) public {
    owner = msg.sender;
    isReleased = false;
    mint(owner, _initialSupply);
  }

  modifier onlyOwner{
    if(msg.sender != owner) revert();_;
  }

  function release() public onlyOwner() {
    isReleased = true; 
  }
  function transfer(address _to, uint256 amount) public {
    require(isReleased == true);
    require(coinBalance[msg.sender]>amount);
    require(coinBalance[_to]+amount>=coinBalance[_to]);
    require(isFrozenAccount[_to]!=true); 
    coinBalance[msg.sender]-=amount;
    coinBalance(_to)+= amount;
    emit Transfer(msg.sender, _to, amount);
  }
}