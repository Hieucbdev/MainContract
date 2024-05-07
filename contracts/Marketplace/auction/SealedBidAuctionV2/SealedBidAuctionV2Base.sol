// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransferETHLib } from "../../utils/TransferETHLib.sol";
import "../../utils/Ownable.sol";
import { IAuctionFactory } from "../../IAuctionFactory.sol";
import "../BaseAuction.sol";

abstract contract SealedBidAuctionV2Base is Ownable, BaseAuction {
  IAuctionFactory factory;
  
  uint256 public basePrice;
  uint256 public revealDuration;
  uint256 public bidEndTime;
  address public paymentToken;
  uint256 public startTime;

  uint256 public bidStep;
  uint256 public revealStep;
  mapping(uint => address) public bidders;

  mapping(address => bytes32) public myPriceHash;
  uint256 public currentBid;
  address public currentBidder;
  bool public isEnded;

  receive() external payable {}

  /*╔═══════════════════════╗
    ║      CONSTRUCTOR      ║
    ╚═══════════════════════╝*/
  function initialize(
    address operator,
    address _factory,
    IAuctionFactory.SealedBidV2Params memory params
  ) internal {
    _setOwner(operator);
    factory = IAuctionFactory(_factory);
    (uint256 mininumBidDuration, uint256 minimumRevealDuration,) = factory.vickreyAdminParams();
    require(params.bidDuration > mininumBidDuration, "Bid duration too small");
    require(params.revealDuration > minimumRevealDuration, "Reveal duration too small");
    basePrice = params.basePrice;
    startTime = block.timestamp + params.waitBeforeStart;
    bidEndTime = startTime + params.bidDuration;
    revealDuration = params.revealDuration;
    paymentToken = params.paymentToken;
  }
  
  function bidAuctionFac(address bidder) internal virtual;
  function revealAuctionFac(address revealer, uint256 actualAmount) internal virtual;

  /*╔══════════════════╗
    ║       BID        ║
    ╚══════════════════╝*/
  function makeOrEditBid(bytes32 priceHash) external {
    require(_msgSender() != owner(), "Auctioneer cannot bid");
    require(block.timestamp <= bidEndTime && block.timestamp >= startTime, "Not bid time");
    require(!isEnded, "Auction has canceled");
    myPriceHash[msg.sender] = priceHash;
    bidders[++bidStep] = msg.sender;
    bidAuctionFac(_msgSender());
  }
  /*╔═════════════════╗
    ║      CANCEL     ║
    ╚═════════════════╝*/
  function cancelAuction() external onlyOwner {
    require(
      //!!!! Sửa để auction end thì vẫn cancel được nếu chưa có ai reveal trước đó
      bidStep == 0 || (revealStep == 0 && block.timestamp > bidEndTime + revealDuration),
      "Cannot cancel ongoing auction"
    );
    isEnded = true;
    transferNFT(address(this), _msgSender());
    finalizeFac();
  }

  /*╔══════════════════════╗
    ║       REVEEAL        ║
    ╚══════════════════════╝*/
  function reveal(
    uint256 price,
    bytes32 salt
  ) external payable nonReentrant {
    require(
      //!!!!! Sửa để nếu quá hạn mà chưa có ai reveal thì vẫn được reveal nếu chưa cancel
      isEnded == false && block.timestamp > bidEndTime && (
        revealStep == 0 || ( block.timestamp <= bidEndTime + revealDuration )
      ),
      "Not time to reveal"
    );
    require(
      myPriceHash[msg.sender] == keccak256(abi.encodePacked(price, salt)), 
      "Price hash invalid"
    );
    //!!!! Dùng starting Price nè!
    require(price > currentBid && price > basePrice, "Not highest bidder");
    if(paymentToken == address(0)){
      require(msg.value == price, "Price not match");
    } else {
      IERC20(paymentToken).transferFrom(msg.sender, address(this), price);
    }
    if(currentBidder!= address(0)){
      // Rate 5% fee
      if(revealStep == 1){
        sendTokenFromThisContractTo(currentBidder, currentBid + price / 20);
      } else {
        sendTokenFromThisContractTo(currentBidder, currentBid - currentBid / 20 + price / 20);
      }
    }
    currentBidder = msg.sender;
    currentBid = price;
    revealStep++;
    revealAuctionFac(currentBidder, currentBid);
    //!!!!! Tự động claim win nếu là người đầu tiên quá hạn
    if(block.timestamp > bidEndTime + revealDuration && revealStep == 1){
      claimWin();
    }
  }

  function claimWin() external nonReentrant {
    require(isEnded == false, "Auction has been claimed"); //!!!! Mới sửa
    isEnded = true;
    require(block.timestamp > bidEndTime + revealDuration, "Not time to claim");
    require(currentBidder != address(0), "No one revealed");
    transferNFT(address(this), currentBidder);
    sendTokenFromThisContractTo(owner(), currentBid);
    finalizeFac();
  }
  /*  ╔═════════════════════════╗
      ║        UTILITIES        ║
      ╚═════════════════════════╝ */  
  // function getRemainingBidTime() public view returns(uint256) {
  //   return bidEndTime > block.timestamp ? bidEndTime - block.timestamp : 0;
  // }
  // function getRemainingRevealTime() public view returns(uint256) {
  //   if(bidEndTime > block.timestamp || bidEndTime + revealDuration < block.timestamp){
  //     return 0;
  //   }
  //   return bidEndTime + revealDuration - block.timestamp;
  // }
  function getAuctionInfo() external view 
    returns (address, uint256, uint256, uint256, uint256, address, uint256, uint256, uint256, address, bool) 
  {
    return (
      owner(),
      basePrice,
      startTime,
      bidEndTime,
      revealDuration,
      paymentToken,
      bidStep,
      revealStep,
      currentBid,
      currentBidder,
      isEnded //!!!! Bỏ, dùng status của graph đi
    );
  }

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
    if(amount > 0) {
      if(paymentToken == address(0)){
        TransferETHLib.transferETH(to, amount, IAuctionFactory(factory).WETH_ADDRESS());
      } else {
        _payout(address(this), to, amount);
      }
    }
  }
}
