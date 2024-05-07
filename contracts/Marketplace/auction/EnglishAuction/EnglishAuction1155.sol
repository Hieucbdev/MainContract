//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "../../IAuctionFactory.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./EnglishAuctionBase.sol";
import "../Store1155.sol";

contract EnglishAuction1155 is EnglishAuctionBase, ERC1155Holder, Store1155 {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint256[] memory _nftIds,
    uint256[] memory _nftValues,
    IAuctionFactory.EnglishParams memory params
  ) external initializer {
    EnglishAuctionBase.initialize(operator, _factory, params);
    Store1155.initialize(_NFTContractAddress, _nftIds, _nftValues);
  }

  function transferNFT(address from, address to) internal override {
    Store1155.transferERC1155(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(1);
  }
  function updateAuctionFac() internal override {
    IAuctionFactory(factory).updateAuctionInFactory(1);
  }
  function bidAuctionFac(address bidder, uint256 amount) internal override {
    IAuctionFactory(factory).bidAuctionInFactory(1, bidder, amount);
  }
}