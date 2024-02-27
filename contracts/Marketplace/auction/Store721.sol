//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Store721 {
  address[] public NFTContractAddress;
  uint256[] public tokenId;

  function initialize(
    address[] memory _NFTContractAddress,
    uint256[] memory _tokenId
  ) internal {
    NFTContractAddress = _NFTContractAddress;
    tokenId = _tokenId;
  }

  function transferERC721(address from, address to) internal {
    for(uint256 i = 0; i < NFTContractAddress.length; i++) {
      IERC721(NFTContractAddress[i]).safeTransferFrom(from, to, tokenId[i]);
    }
  }
  function getNFTInfo() external view returns(address[] memory, uint256[] memory) {
    return (NFTContractAddress, tokenId);
  }
}