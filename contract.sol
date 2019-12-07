pragma solidity ^0.4.24;



library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}



contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function transfer(address to, uint tokens) public returns (bool success);

    function allowance(address holder, address spender) public constant returns (uint);

    function transferFrom(address from, address to, uint value) public returns (bool ok);

    function approve(address spender, uint value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint tokens);
 
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Owned {

    address public owner;

    function transferOwnership(address newOwner) public returns(bool success);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event SetRate(uint64 newRate);

    constructor() public{

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }
}




contract GMT is ERC20Interface, Owned {

    using SafeMath for uint;


    string public symbol;

    string public  name;

    uint public _totalSupply;

    uint64 public rate;

    

    mapping(address => uint) balances;

      /* approve() allowances */
    mapping (address => mapping (address => uint)) allowed;

    event Burn(address indexed from, uint256 value);

    



    constructor() public {

        symbol = "GMT";

        name = "GoldMint Token";

        rate = 10;

        _totalSupply = 1000;

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }




    function () public payable {
        require(
            msg.value > 0 &&
            balances[owner] >= msg.value.mul(rate)
           
        );
      
        uint256 tokens = msg.value.mul(rate);
        balances[owner] = balances[owner].sub(tokens);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        owner.transfer(msg.value);
        emit Transfer (owner,msg.sender,tokens);

    }




    function transferOwnership(address newOwner) public onlyOwner  returns(bool success) {
   
        require(newOwner != address(0));
        balances[newOwner] = balances[owner];
        balances[owner] = 0;
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
 
    }




    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint) {

        return _totalSupply ;

    }
    
   

    function currentRate() public view returns (uint) {

        return rate;

    }
   

    function currentOwner() public view returns (address) {

        return owner;

    }



    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }



    function transfer(address to, uint tokens) public  returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }
    
    function setRate(uint64 newRate) public onlyOwner  returns (bool success) {
        
        rate = newRate;
        emit SetRate(rate);        
        return true;

    }





    function approve(address _spender, uint _value) public  returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
    
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _holder, address _spender) public constant returns (uint remaining) {
        return allowed[_holder][_spender];
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

}

