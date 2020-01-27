pragma solidity >=0.4.22 <0.6.0;
contract Counter {
    
    bytes public value;
    
    constructor() public {
    }
    
    function setString(bytes memory _value) public returns(bool){
        value = _value;
        return true;
    }
    
    function getString() public view returns(bytes memory){
        return value;
    }

}
