//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "../../IAuctionFactory.sol";
import "./EnglishAuctionBase.sol";
import "../Store721.sol";

contract EnglishAuction721 is EnglishAuctionBase, Store721 {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint256[] memory _tokenId,
    IAuctionFactory.EnglishParams memory params
  ) external initializer {
    EnglishAuctionBase.initialize(operator, _factory, params);
    Store721.initialize(_NFTContractAddress, _tokenId);
  }

  function transferNFT(address from, address to) internal override {
    Store721.transferERC721(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(0);
  }
}