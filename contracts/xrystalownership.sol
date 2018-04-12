pragma solidity ^0.4.19;

import "./xrystalhelper.sol";
import "./erc721.sol";


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
        Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        xrystalApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public {
        require(xrystalApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
}
