pragma solidity ^0.5.11;

/**
 * The Owned contract make sure that a token is owned by someone, and can be passed along
 */
contract Owned{
	address public owner;
	address public newOwner;

	/**
	* @dev Event to be fired whenever the ownership of the contract is transferred. 
	*/
	event OwnershipTransferred(address indexed _from, address indexed _to);
		
	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

 	/**
 	* @dev Transfer the ownership, only executeable from owner
 	*/
	function transferOwnership(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	/**
	* @dev Accept the ownership of the contract. Will be reverted if not executed by the newOwner
	*/
	function acceptOwnership() public {
		require(msg.sender == newOwner);
		owner = newOwner;
		// Make sure that no prior newOwner is able to perform acceptOwnership().
		newOwner = address(0);
		emit OwnershipTransferred(owner, newOwner);
	}
}

/**
 * The MerkleRoot contract does this and that...
 */
contract MerkleRoot is Owned{

	struct Root {
		address party_a;
		address party_b;
		bytes root;
		bool accepted;
	}

	Root[] public roots;

	constructor() public {
	}

	function createRoot(address _party_b, bytes memory _root) public returns(uint) {
		Root memory _new = Root(msg.sender, _party_b, _root, false);
		roots.length++;
		uint roots_id = roots.length - 1;
		roots[roots_id] = _new;
		return roots_id;
	}

	function aceeptRoot (uint _index) public returns(bool)  {
		require(msg.sender == roots[_index].party_b, "You are not an eligible party");
		roots[_index].accepted = true;
		return true;
	}

	function getPartyA (uint _index) public view returns(address){
		return roots[_index].party_a;		
	}
	
	function getPartyB (uint _index) public view returns(address){
		return roots[_index].party_b;		
	}

	function getRoot(uint _index) public view returns(bytes memory){
		return roots[_index].root;
	}
	
	function isAccepted(uint _index) public view returns(bool){
		return roots[_index].accepted;
	}

}

