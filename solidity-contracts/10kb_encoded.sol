pragma solidity >=0.4.22 <0.6.0;
contract Counter {
    
    string public value;
    
    constructor() public {
    }
    
    function setString(string memory _value) public returns(bool){
        value = _value;
        return true;
    }
    
    function getString() public view returns(string memory){
        return value;
    }

}
