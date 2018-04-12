pragma solidity ^0.4.19;

import "./ownable.sol";
import "./safemath.sol";


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

    mapping (uint => address) public xrystalToOwner;
    mapping (address => uint) ownerXrystalCount;

    function _createXrystal(string _name, uint _dna) internal {
        uint id = xrystals.push(Xrystal(_name, _dna, 0, "", "", "")) - 1;
        xrystalToOwner[id] = msg.sender;
        ownerXrystalCount[msg.sender] = ownerXrystalCount[msg.sender].add(1);
        NewXrystal(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomXrystal(string _name) public {
        require(ownerXrystalCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createXrystal(_name, randDna);
    }
}
