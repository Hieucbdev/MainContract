// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "../../IAuctionFactory.sol";
import "./SealedBidAuctionV1Base.sol";
import "../Store721.sol";

contract SealedBidAuctionV1721 is SealedBidAuctionV1Base, Store721 {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint256[] memory _tokenId,
    IAuctionFactory.VickreyParams memory params
  ) external initializer {
    SealedBidAuctionV1Base.initialize(operator, _factory, params);
    Store721.initialize(_NFTContractAddress, _tokenId);
  }

  function transferNFT(address from, address to) internal override {
    Store721.transferERC721(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(6);
  }
  function revealAuctionFac(address revealer, uint256 actualAmount) internal override {
    IAuctionFactory(factory).revealAuctionInFactory(6, revealer, actualAmount);
  }
  function startRevealFac() internal override {
    IAuctionFactory(factory).startRevealAuctionInFactory(6);
  }
}
