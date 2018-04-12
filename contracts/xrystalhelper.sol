pragma solidity ^0.4.19;

import "./xrystalfactory.sol";


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
        owner.transfer(this.balance);
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
