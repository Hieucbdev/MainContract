// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "../../IAuctionFactory.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./VickreyAuctionBase.sol";
import "../Store1155.sol";

contract VickreyAuction1155 is VickreyAuctionBase, ERC1155Holder, Store1155 {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint[] memory _nftIds,
    uint[] memory _nftValues,
    IAuctionFactory.VickreyParams memory params
  ) external initializer {
    VickreyAuctionBase.initialize(operator, _factory, params);
    Store1155.initialize(_NFTContractAddress, _nftIds, _nftValues);
  }

  function transferNFT(address from, address to) internal override {
    Store1155.transferERC1155(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(3);
  }
  function startRevealFac() internal override {
    IAuctionFactory(factory).startRevealAuctionInFactory(3);
  }
  function revealAuctionFac(address revealer, uint256 actualAmount) internal override {
    IAuctionFactory(factory).revealAuctionInFactory(3, revealer, actualAmount);
  }
}
