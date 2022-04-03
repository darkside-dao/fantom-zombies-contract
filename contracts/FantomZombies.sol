//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IX32PE.sol";

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

    uint256 public whitelistPrice = 8 ether;

    uint32 private _whitelistMintLimit = 100;

    address payable public payableAddress;

    address private _virusContract;

    string private _defaultBaseURI;

    bool public whitelistSale;

    bool public salesAvailable;

    constructor() ERC721("Fantom Zombies", "ZOMBIES") {
        salesAvailable = false;
        whitelistSale = false;
        _tokenIds.increment();
    }

    modifier whenWhitelistOnline {
        require(whitelistSale, "Whitelist sale isn't on!");
        _;
    }

    function infect() external payable whenWhitelistOnline {
        uint256 balance = IX32PE(_virusContract).balanceOf(msg.sender);
        require(balance > 0, "Amount higher than your balance");
        require(msg.value >= whitelistPrice, "Invalid price!");
        uint256 tokenId = IX32PE(_virusContract).tokenOfOwnerByIndex(msg.sender, 0);
        IX32PE(_virusContract).burnForAddress(tokenId);
        giveaway(msg.sender, 1);
    }

    function infectForAddress(address to) external onlyOwner {
        uint256 balance = IX32PE(_virusContract).balanceOf(to);
        require(balance > 0, "Amount higher than balance");
        uint256 tokenId = IX32PE(_virusContract).tokenOfOwnerByIndex(to, 1);
        IX32PE(_virusContract).burnForAddress(tokenId);
        giveaway(to, 1);
    }

    function mint(uint256 quantity) external payable whenNotPaused {
        uint256 amountMint = _mintCount.current();
        require(amountMint < maxMintable && ((amountMint + quantity) < maxMintable), "Mint limit exceeded!");
        require(salesAvailable, "Sales isn't public yet!");
        
        uint256 totalPrice = mintPrice * quantity;
        require(msg.value >= totalPrice, "Invalid amount!");

        payableAddress.transfer(totalPrice);

        uint256 tokenId = _tokenIds.current();
        for (uint256 i = 0; i < quantity; i++) {
            mintNFT(msg.sender, tokenId + i);
        }
    }

    function giveaway(address to, uint256 quantity) public onlyOwner {
        uint256 amountGiveaway = _giveawayCount.current();
        require(amountGiveaway < maxGiveaway && (amountGiveaway + quantity) < maxGiveaway, "Mint limit exceeded!");
        
        uint256 tokenId = _tokenIds.current();
        for (uint256 i = 0; i < quantity; i++) {
            giveNFT(to, tokenId + i);
        }
    }

    function isWhitelisted(address whitelistedAddress) public view onlyOwner returns (bool) {
        return IX32PE(_virusContract).balanceOf(whitelistedAddress) > 0;
    }

    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You're not the owner");
        _burn(tokenId);
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

    function toggleSalesAvailable() public onlyOwner {
        salesAvailable = !salesAvailable;
    }

    function toggleWhitelistSale() public onlyOwner {
        whitelistSale = !whitelistSale;
    }

    function setVirusAddress(address contractAddress) external onlyOwner {
        _virusContract = contractAddress;
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