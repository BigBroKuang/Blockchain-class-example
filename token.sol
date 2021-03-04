// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

interface Token{
    function balanceOf(address _owner)  external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256  _value);
}

contract TokenABC is Token{
    uint256 public totalSupply;
    string public name;                   //name of the token
    uint8 public decimals=18;               //decimals 
    string public symbol;               //symbol
    mapping (address => uint256) balances;   //balance of the address, hash table
    mapping (address => mapping (address => uint256)) allowed;    //addr1 allows addr2 to spend addr1's tokens

    //initialize the token
    constructor(uint256 _initialSupply, string memory _tokenName, string memory _tokenSymbol) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);         // initial supply
        balances[msg.sender] = totalSupply; // balance of owner is the total supply
        name = _tokenName;               //input the name    
        symbol = _tokenSymbol;      
    }
    
    //make transaction
    function transfer(address _to, uint256  _value) external override returns (bool success) {
        require(balances[msg.sender] >= _value);   //sender has enough balance
        require(balances[_to] + _value > balances[_to]);  //there is no overflow in recipient's account
        balances[msg.sender] -= _value;   //reduce the amount from sender's account
        balances[_to] += _value;    //increase the amount in recipient's account
        emit Transfer(msg.sender, _to, _value);  //emit the transfer event
        return true;   
    }
    
    //make transaction for delegate
    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool success) {
        require(balances[_from] >= _value);  //addr1 has enough balance
        require(allowed[_from][msg.sender] >= _value);  //addr2 has enough allowance from addr1
        balances[_to] += _value; // increase recipient's balance
        balances[_from] -= _value; //reduce sender's balance
        allowed[_from][msg.sender] -= _value;  //reduce the allowed amount
        emit Transfer(_from, _to, _value);  //emit the transfer event
        return true;
    }
    
    //addr1 approves addr2 to transfer addr1's tokens
    function approve(address _spender, uint256 _value) external override returns (bool success)   
    { 
        allowed[msg.sender][_spender] = _value;    //addr1 delegate the right to addr2 with token amount 
        emit Approval(msg.sender, _spender, _value);  //trigger the event
        return true;
    }
    
    //the balance of an account 
    function balanceOf(address _owner) external view override returns (uint256 balance) {
        return balances[_owner];   //return the balance of an account
    }
    
    //the allowance of an account 
    function allowance(address _owner, address _spender) external view override returns (uint256 remaining) {
        return allowed[_owner][_spender]; //allowance of addr2 from addr1
    }

}











