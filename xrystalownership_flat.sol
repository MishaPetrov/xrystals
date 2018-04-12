pragma solidity ^0.4.19;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    function Ownable() public {
        owner = msg.sender;
    }
  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}



contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    /*function ownerOf(uint256 _tokenId) public view returns (address _owner);*/
    function transfer(address _to, uint256 _tokenId) public;
    function approve(address _to, uint256 _tokenId) public;
    function takeOwnership(uint256 _tokenId) public;
}








contract XrystalFactory is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeMath for uint16;

    event NewXrystal(uint xrystalId, string name, uint dna);

    uint dnaDigits = 256;
    uint dnaModulus = 10 ** dnaDigits;

    struct Xrystal {
        string name;
        uint dna;
        uint32 age;
        string gps;
        string data1;
        string data2;
    }

    Xrystal[] public xrystals;

    uint xrystalCreationFee = 0.0022 ether;

    mapping (uint => address) public xrystalToOwner;
    mapping (address => uint) ownerXrystalCount;

    function _createXrystal(string _name, uint _dna) internal {
        uint id = xrystals.push(Xrystal(_name, _dna, 0, "", "", "")) - 1;
        xrystalToOwner[id] = msg.sender;
        ownerXrystalCount[msg.sender] = ownerXrystalCount[msg.sender].add(1);
        emit NewXrystal(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomXrystal(string _name) public payable {
        require(msg.value == xrystalCreationFee);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createXrystal(_name, randDna);
    }
}






contract XrystalHelper is XrystalFactory {

    modifier onlyOwnerOf(uint _xrystalId) {
        require(msg.sender == xrystalToOwner[_xrystalId]);
        _;
    }

    function changeName(uint _xrystalId, string _newName) external onlyOwnerOf(_xrystalId) {
        require(msg.sender == xrystalToOwner[_xrystalId]);
        xrystals[_xrystalId].name = _newName;
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function getXrystalsByOwner(address _owner) external view returns(uint[]) {
        uint[] memory result = new uint[](ownerXrystalCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < xrystals.length; i++) {
            if (xrystalToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }



}




contract XrystalOwnership is XrystalHelper, ERC721 {

    using SafeMath for uint256;

    mapping (uint => address) xrystalApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerXrystalCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return xrystalToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerXrystalCount[_to].add(1);
        ownerXrystalCount[_from].sub(1);
        xrystalToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        xrystalApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public {
        require(xrystalApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
}
