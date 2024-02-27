//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../IAuctionFactory.sol";
import "../../utils/TransferETHLib.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../../utils/Ownable.sol";
import "../BaseAuction.sol";

abstract contract DutchAuctionBase is Ownable, BaseAuction {
  address factory;
  uint256 minimumPrice;
  uint256 startingPrice;
  uint256 numberOfStep;
  uint256 stepDuration;
  address paymentToken;
  uint256 startingTime;
  bool isEnded;

  /*╔══════════════════════════════╗
    ║            EVENTS            ║
    ╚══════════════════════════════╝*/
  event AuctionBid(
    address nftBidder,
    uint256 bidPrice
  );
  event AuctionCancelled(address nftSeller);

  /*╔══════════════════════════════╗
    ║          CONSTRUCTOR         ║
    ╚══════════════════════════════╝*/
  function initialize(
    address operator,
    address _factory,
    IAuctionFactory.DutchParams memory params
  ) internal {
    _setOwner(operator);
    factory = _factory;

    minimumPrice = params.minimumPrice;
    startingPrice = params.startingPrice;
    numberOfStep = params.numberOfStep;
    stepDuration = params.stepDuration;
    paymentToken = params.paymentToken;

    startingTime = block.timestamp;
  }

  /*╔══════════════════════════════╗
    ║       CANCEL AUCTION         ║
    ╚══════════════════════════════╝*/
  function cancelAuction() external nonReentrant onlyOwner {
    require(isEnded == false, "Auction ended");
    isEnded = true;
    transferNFT(address(this), _msgSender());
    finalizeFac();
    emit AuctionCancelled(_msgSender());
  }

  /*╔════════════════════════╗
    ║          BUY           ║
    ╚════════════════════════╝*/
  function _buy(uint256 _bidPrice) internal {
    (uint256 currentPrice,,) = getCurrentStepData();
    require(isEnded == false, "Auction ended");
    require(_bidPrice >= currentPrice, "Bid price too low");
    transferNFT(address(this), _msgSender());
    sendTokenFromThisContractTo(owner(), currentPrice);
    uint256 refund = _bidPrice - currentPrice;
    if(refund > 0) {
      sendTokenFromThisContractTo(msg.sender, refund);
    }
    finalizeFac();
    isEnded = true;
    emit AuctionBid(msg.sender, _bidPrice);
  }
  function buy(uint256 _bidPrice) external payable nonReentrant {
    require(_msgSender() != owner(), "Auctioneer cannot bid");
    if(paymentToken == address(0)){
      _buy(msg.value);
    } else {
      _buy(_bidPrice);
    }
  }

  /*  ╔═════════════════════════╗
      ║        UTILITIES        ║
      ╚═════════════════════════╝ */
  function _payout(
    address _sender,
    address _recipient,
    uint256 _amount
  ) internal {
    if(_sender == address(this)){
      IERC20(paymentToken).transfer(_recipient, _amount);
    } else {
      IERC20(paymentToken).transferFrom(_sender, _recipient, _amount);
    }
  }
  function sendTokenFromThisContractTo(address to, uint256 amount) internal {
    if(paymentToken == address(0)){
      TransferETHLib.transferETH(to, amount, IAuctionFactory(factory).WETH_ADDRESS());
    } else {
      _payout(address(this), to, amount);
    }
  }

  /*╔══════════════════════════════╗
    ║            GETTERS           ║
    ╚══════════════════════════════╝*/
  function getCurrentStepData() public view 
  returns (uint256 currentPrice, uint256 currentRemainingTime, uint256 currentStep) 
  {
    currentStep = Math.min(((block.timestamp - startingTime) / stepDuration) + 1, numberOfStep);
    currentPrice = startingPrice - (currentStep - 1) * ((startingPrice - minimumPrice) / numberOfStep);
    currentRemainingTime = stepDuration - ((block.timestamp - startingTime) % stepDuration);
  }
  // Để frontend lấy progress = time elapsed / (numberOfStep*stepDuration)
  function getTimeElapsed() external view returns (uint256) {
    return (block.timestamp - startingTime);
  }
  function getAuctionInfo() external view 
  returns(uint256, uint256, uint256, uint256, address, uint256, bool) {
    return (
      minimumPrice, startingPrice, numberOfStep, stepDuration, paymentToken, startingTime, isEnded);
  }
}