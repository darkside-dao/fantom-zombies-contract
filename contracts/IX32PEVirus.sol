//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract IX32PEVirus is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    string public defaultURI;

    address private _infectionContract;

    constructor() ERC721("IX32PE Virus", "IX32PE") {
        defaultURI = "";
        _tokenIds.increment();
    }

    function burnForAddress(uint256 tokenId) external {
        require(msg.sender == _infectionContract, "Invalid burner address");
        _burn(tokenId);
    }

    function airdropViruses(address[] calldata to, uint256[] calldata amount) external onlyOwner {
        for (uint i = 0; i < to.length; i++) {
            internalAirdropVirus(to[i], amount[i]);
        }
    }

    function airdropVirus(address to, uint256 amount) public onlyOwner {
        internalAirdropVirus(to, amount);
    }

    function internalAirdropVirus(address to, uint256 amount) internal onlyOwner {
        uint256 tokenId = _tokenIds.current();
        for (uint256 i = 0; i < amount; i++) {
            internalMint(to, tokenId + i);
        }
    }

    function setInfectionContract(address contractAddress) external onlyOwner {
        _infectionContract = contractAddress;
    }

    function internalMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId);
        _tokenIds.increment();
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        defaultURI = newURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return defaultURI;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return _baseURI();
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}