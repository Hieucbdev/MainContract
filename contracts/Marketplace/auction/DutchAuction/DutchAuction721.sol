//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "../../IAuctionFactory.sol";
import "./DutchAuctionBase.sol";
import "../Store721.sol";

contract DutchAuction721 is DutchAuctionBase, Store721 {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint256[] memory _tokenId,
    IAuctionFactory.DutchParams memory params
  ) external initializer {
    DutchAuctionBase.initialize(operator, _factory, params);
    Store721.initialize(_NFTContractAddress, _tokenId);
  }

  function transferNFT(address from, address to) internal override {
    Store721.transferERC721(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(4);
  }
  function bidAuctionFac(address bidder, uint256 amount) internal override {
    IAuctionFactory(factory).bidAuctionInFactory(4, bidder, amount);
  }
}