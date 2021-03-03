// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public; }

contract TokenERC20 {
    string public name; 
    string public symbol;
    uint8 public decimals=18;  // 18 is recommended
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;  // the balance of the account
    mapping (address => mapping (address => uint256)) public allowance; //addr1 allows addr2 to spend uint256 tokens

    event Transfer(address indexed from, address indexed to, uint256 value); //record the transaction on ETH chain
    event Burn(address indexed from, uint256 value); //otherwise, the transactions are recorded btween contract and sender

    //basics of the token
    function ERCToken(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals); //min unit as in ethereum
        balanceOf[msg.sender] = totalSupply;  //the amount of token in the owner's account
        name = tokenName;                     //token name (e.g. chainlink)
        symbol = tokenSymbol;                 //token symbol(e.g. LINK)
    }

    //an internal function, define the transaction in the token system
    function _transfer(address _from, address _to, uint _value) internal {   //sender, recipient, amount
        assert(balanceOf[_from] >= _value);         //sender has enough balance
        assert(balanceOf[_to] + _value > balanceOf[_to]);   //to verify there is no overflow
        uint previousBalances = balanceOf[_from] + balanceOf[_to];  // balances of the 2 accounts before the transaction
        balanceOf[_from] -= _value;   //reduce the balance in sender's account
        balanceOf[_to] += _value;     //increase the balance in recipient's account 
        emit Transfer(_from, _to, _value);    //emit an event when there is a transaction
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  //double check the balances of the 2 accounts
    }
    
    //this function calls the internal transaction function
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);   //the message sender is the sender
    }

     //transfer token with delegate's account
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //addr1 has enough balance. addr2 initiates the transaction
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] -= _value;   //decrease the allowance of addr2
        _transfer(_from, _to, _value);    //initiate the transaction with addr1
        return true;
    }

    //addr1 approves addr2 to spend addr1's token
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;   //the allowance for addr2
        return true;
    }
    
    
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
   
    //to burn some tokens for a user
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value); //the amount to burn is less than the balance 
        balanceOf[msg.sender] -= _value;    //burn the amount token for the user
        totalSupply -= _value;               //total supply has to be changed
        emit Burn(msg.sender, _value);       //emit an event
        return true;
    }

    //addr2 burns some tokens for addr1
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);   //the amount to burn is less than the balance 
        require(_value <= allowance[_from][msg.sender]);  //allowance for addr2 is greater than the amount
        balanceOf[_from] -= _value;   //burn the tokens for addr
        allowance[_from][msg.sender] -= _value;  //reduce the amount in allowance
        totalSupply -= _value;   //reduce the total supply
        emit Burn(_from, _value);  //emit an event
        return true;
    }
}
