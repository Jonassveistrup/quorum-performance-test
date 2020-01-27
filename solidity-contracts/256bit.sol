pragma solidity >=0.4.22 <0.6.0;
contract Counter {
    
    uint256 counter = 0;
    
    constructor() public {
    }
    
    function increment() public{
        counter = counter + 1;
    }
    
    function reset() public{
        counter = 0;
    }
    
    function getCounter() public view returns(uint256){
        return counter;
    }
    

}
