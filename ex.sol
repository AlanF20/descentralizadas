// SPDX-License-Identifier: UNKNOWN 
pragma solidity 0.8.19;

contract Token{
  enum UserType{
    TokenHolder,
    Admin,
    Owner
  }
  struct UserInfo{ 
    address account;
    string firstName;
    string lastName;
    UserType userType;
  }
  mapping(address => uint) public tokenBalance;
  mapping(address => UserInfo) public registeredUser;
  mapping(address => bool) isFrozenAccount;

  address public owner= 0x578B5dc7645a6424847C128B17393A08Db9884ee;
  uint256 public constant maxTransferLimit = 15000;
  
  event Transfer(address from, address to, uint256 value);
  event FreezeAccount(address target, bool isFrozen);

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  constructor (uint256 _initialSupply) public {
    owner = msg.sender; 
  }
}