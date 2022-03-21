//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FantomZombies is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    Counters.Counter private _mintCount;

    Counters.Counter private _giveawayCount;

    Counters.Counter private _whitelistCount;

    uint256 public maxMintable = 980;

    uint256 public maxTokens = 1000;

    uint256 public maxGiveaway = 20;

    uint256 public mintPrice = 10 ether;

    uint32 private _whitelistMintLimit = 100;

    mapping(address => bool) private _whitelist;

    address[100] private _whitelisted;

    address payable public payableAddress;

    string private _defaultBaseURI;

    bool public whitelistSale;

    constructor() ERC721("Fantom Zombies", "ZOMBIES") {
        closedSales();
    }

    function mint(uint256 quantity) external payable whenNotPaused {
        uint256 amountMint = _mintCount.current();
        require(amountMint < maxMintable && ((amountMint + quantity) < maxMintable), "Mint limit exceeded!");

        if ((whitelistSale && _whitelist[msg.sender]) || !whitelistSale) {
            uint256 totalPrice = mintPrice * quantity;
            require(msg.value >= totalPrice, "Invalid amount!");

            payableAddress.transfer(totalPrice);

            uint256 tokenId = _tokenIds.current();
            for (uint256 i = 0; i < quantity; i++) {
                mintNFT(msg.sender, tokenId + i);
            }
        }
    }

    function giveaway(address to, uint256 quantity) external payable onlyOwner {
        uint256 amountGiveaway = _giveawayCount.current();
        require(amountGiveaway < maxGiveaway && (amountGiveaway + quantity) < maxGiveaway, "Mint limit exceeded!");
        
        uint256 tokenId = _tokenIds.current();
        for (uint256 i = 0; i < quantity; i++) {
            giveNFT(to, tokenId + i);
        }
    }

    function mintNFT(address to, uint256 tokenId) internal {
        internalMint(to, tokenId);
        _mintCount.increment();
    }

    function giveNFT(address to, uint256 tokenId) internal {
        internalMint(to, tokenId);
        _giveawayCount.increment();
    }

    function internalMint(address to, uint256 tokenId) internal {
        require(tokenId <= maxTokens, "Token limit exceeded!");
        _safeMint(to, tokenId);
        _tokenIds.increment();
    }

    function whitelist(address target) public onlyOwner {
        require(target != address(0), "Cannot whitelist zero address");
        _whitelisted[_whitelistCount.current()] = target;
        _whitelistCount.increment();
        _whitelist[target] = true;
    }

    function isWhitelisted(address target) public view returns (bool) {
        require(target != address(0), "Cannot check zero address");
        return _whitelist[target];
    }

    function openSales() public onlyOwner {
        whitelistSale = false;
    }

    function closedSales() public onlyOwner {
        whitelistSale = true;
    }

    function setBaseURI(string calldata newBaseURI) public onlyOwner {
        _defaultBaseURI = newBaseURI;
    }

    function setPayableAddress(address newPayableAddress) public onlyOwner {
        payableAddress = payable(newPayableAddress);
    }

    function setMintPrice(uint256 newMintPrice) public onlyOwner {
        mintPrice = newMintPrice;
    }

    function setMaxGiveaway(uint256 newMaxGiveaway) public onlyOwner {
        maxGiveaway = newMaxGiveaway;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    function _baseURI() internal view override returns (string memory) {
        return _defaultBaseURI;
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