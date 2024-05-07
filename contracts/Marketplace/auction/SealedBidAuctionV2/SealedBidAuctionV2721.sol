// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "../../IAuctionFactory.sol";
import "./SealedBidAuctionV2Base.sol";
import "../Store721.sol";

contract SealedBidAuctionV2721 is SealedBidAuctionV2Base, Store721 {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint256[] memory _tokenId,
    IAuctionFactory.SealedBidV2Params memory params
  ) external initializer {
    SealedBidAuctionV2Base.initialize(operator, _factory, params);
    Store721.initialize(_NFTContractAddress, _tokenId);
  }

  function transferNFT(address from, address to) internal override {
    Store721.transferERC721(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(8);
  }
  function bidAuctionFac(address bidder) internal override {
    IAuctionFactory(factory).bidAuctionInFactory(8, bidder, 0);
  }
  function revealAuctionFac(address revealer, uint256 actualAmount) internal override {
    IAuctionFactory(factory).revealAuctionInFactory(8, revealer, actualAmount);
  }
}
