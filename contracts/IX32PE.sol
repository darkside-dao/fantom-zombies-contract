//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IX32PE {
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function burnForAddress(uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}