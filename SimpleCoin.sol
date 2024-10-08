// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;

contract SimpleCoin{
  address owner;
  mapping(address => uint256) public coinBalance;
  mapping(address => bool) public FrozenAccounts;

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
    require(FrozenAccounts[_to]!=true); 
    coinBalance[msg.sender]-=amount;
    coinBalance[_to]+= amount;
    emit Transfer(msg.sender, _to, amount);
  }
  
  function mint(address recipient, uint256 _mintedAmount) public onlyOwner {
    require(msg.sender == owner);
    coinBalance[recipient] += _mintedAmount;
    emit Transfer(owner, recipient, _mintedAmount);
  }

  function freezeAccount(address target, bool freeze)public onlyOwner {
   require(msg.sender == owner);
   FrozenAccounts[target] = freeze;
   emit FreezeAccount(target, freeze);
  }

  mapping(address => mapping(address => uint256)) public allowance;

  function setAllowance(uint coins, address address1, address address2)public {
    allowance[address1][address2] = coins;
  }

  function authorize(address _authAccount, uint256 _allowance)public returns(bool success) {
    allowance[msg.sender][_authAccount] = _allowance; 
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _amount)public returns(bool success) {
    require(_to != address(0)); 
    require(coinBalance[_from] > _amount);
    require(coinBalance[_to] + _amount > coinBalance[_to]);
    require(_amount <= allowance[_from][msg.sender]);
    coinBalance[_from] -= _amount;
    coinBalance[_to] += _amount;
    allowance[_from][msg.sender] -= _amount;
    emit Transfer(_from, _to, _amount);
    return true;
  }
}