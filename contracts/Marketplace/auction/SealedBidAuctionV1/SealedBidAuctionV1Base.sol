// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import { TransferETHLib } from "../../utils/TransferETHLib.sol";
import { MPT } from "lib-auction/contracts/MPT.sol";
import { EthereumDecoder } from "lib-auction/contracts/EthereumDecoder.sol";
import { IAuctionFactory } from "../../IAuctionFactory.sol";
import "lib-auction/contracts/IVickreyUtilities.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../BaseAuction.sol";

abstract contract SealedBidAuctionV1Base is BaseAuction {
  address owner;
  IAuctionFactory public factory;
  
  uint256 public basePrice;
  uint256 public revealDuration;
  uint256 public bidEndTime;
  IVickreyUtilities utilities;

  bytes32 public storedBlockHash;
  uint256 public revealStartTime;
  uint256 public revealBlockNum;
  address public topBidder;
  uint128 public topBid;
  bool public isClaimed;

  /*╔═══════════════════════╗
    ║        EVENTS         ║
    ╚═══════════════════════╝*/
  event RevealStarted();
  event BidRevealed(
    address indexed topBidder,
    uint256 topBid,
    address indexed bidder,
    uint256 bid
  );
  event WinClaimed(address indexed winner, uint256 paidBid);
  event Slashed(address indexed bidder, uint256 paidBid, uint256 slashed);
  event ClaimNoBidder();

  /*╔═══════════════════════╗
    ║        ERRORS         ║
    ╚═══════════════════════╝*/
  error NotYetRevealBlock();
  error NotYetReveal();
  error RevealAlreadyStarted();
  error RevealOver();
  error InvalidProof();
  error RevealNotOver();
  error RevealInProgress();

  /*╔═══════════════════════╗
    ║       CONSTANTS       ║
    ╚═══════════════════════╝*/
  uint256 internal constant BID_EXTRACTOR_CODE = 0x3d3d3d3d47335af1;
  uint256 internal constant BID_EXTRACTOR_CODE_SIZE = 0x8;
  uint256 internal constant BID_EXTRACTOR_CODE_OFFSET = 0x18;
  uint256 constant WAD = 1e18;
  uint256 internal constant SLASH_AMT = 0.1e18; // amount to slash for late reveal = 10%

  receive() external payable {}

  /*╔═══════════════════════╗
    ║      CONSTRUCTOR      ║
    ╚═══════════════════════╝*/
  function initialize(
    address operator,
    address _factory,
    IAuctionFactory.VickreyParams memory params
  ) internal {
    owner = operator;
    factory = IAuctionFactory(_factory);
    (
      uint256 mininumBidDuration, 
      uint256 minimumRevealDuration, 
      address VICKREY_UTILITIES
    ) = factory.vickreyAdminParams();

    basePrice = params.basePrice;
    require(params.bidDuration > mininumBidDuration, "Bid duration too small");
    require(params.revealDuration > minimumRevealDuration, "Reveal duration too small");
    revealDuration = params.revealDuration;
    bidEndTime = block.timestamp + params.bidDuration;
    utilities = IVickreyUtilities(VICKREY_UTILITIES);
  }

  /*╔══════════════════════╗
    ║       REVEEAL        ║
    ╚══════════════════════╝*/
  function startReveal() external {
    if (storedBlockHash != bytes32(0)) revert RevealAlreadyStarted();
    _startReveal();
  }
  function _startReveal() internal {
    if (block.timestamp < bidEndTime) revert NotYetRevealBlock();
    require(!factory.isLocked(), "Contract is locked!");
    revealBlockNum = block.number - Math.min(block.timestamp - bidEndTime, 600) / utilities.getAverageBlockTime();
    storedBlockHash = blockhash(revealBlockNum);
    if(storedBlockHash == bytes32(0)){
      storedBlockHash = blockhash(block.number - 1);
      revealBlockNum = block.number - 1;
    }
    revealStartTime = uint(block.timestamp);
    emit RevealStarted();
  }

  // Not first reveal and being the highest
  function reveal(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt,
    uint256 _balAtSnapshot,
    EthereumDecoder.BlockHeader memory _header,
    MPT.MerkleProof memory _accountDataProof
  ) external nonReentrant returns(address) {
    if (storedBlockHash == bytes32(0)) _startReveal();
    if (revealStartTime + revealDuration < block.timestamp) revert RevealOver();
    return _reveal(_bidder, _bid, _subSalt, _balAtSnapshot, _header, _accountDataProof);
  }

  function _reveal(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt,
    uint256 _balAtSnapshot, 
    EthereumDecoder.BlockHeader memory _header,
    MPT.MerkleProof memory _accountDataProof
  ) internal returns(address bidAddr) {
    uint256 totalBid; 
    {
      (bytes32 salt, address depositAddr) = getBidDepositAddr(
        _bidder,
        _bid,
        _subSalt
      );
      if (
        !utilities.verifyProof(
          _header,
          _accountDataProof,
          _balAtSnapshot,
          depositAddr,
          storedBlockHash
        )
      ) revert InvalidProof();
      (totalBid, bidAddr) = takeCreate2(salt);
    }

    uint256 actualBid = Math.min(_bid, _balAtSnapshot);
    require(actualBid > 0, "You bid nothing");
    if(actualBid < basePrice){
      TransferETHLib.transferETH(_bidder, actualBid, factory.WETH_ADDRESS());
      return bidAddr;
    }
    uint256 bidderRefund = totalBid - actualBid;
    uint128 topBidCached = topBid;
    address topBidderCached = topBidder;
    
    if (actualBid > topBid) {
      TransferETHLib.transferETH(topBidder, topBid, factory.WETH_ADDRESS());
      topBidder = _bidder;
      topBid = uint128(actualBid);
    } else {
      bidderRefund += actualBid;
    }

    if(bidderRefund > 0) {
      TransferETHLib.transferETH(_bidder, bidderRefund, factory.WETH_ADDRESS());
    }

    emit BidRevealed(
      topBidderCached, // old val
      topBidCached, // old val
      _bidder, // new val
      actualBid // new val
    );
  }

  // First reveal or reveal but not highest bidder
  function revealNoVerify(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt
  ) external nonReentrant returns(address bidAddr) {
    if (storedBlockHash == bytes32(0)) _startReveal();
    if (revealStartTime + revealDuration < block.timestamp) revert RevealOver();
    return _revealNoVerify(_bidder, _bid, _subSalt);
  }
  function _revealNoVerify(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt
  ) internal returns(address bidAddr)
  {
    uint256 totalBid;
    {
      (bytes32 salt,) = getBidDepositAddr(
        _bidder,
        _bid,
        _subSalt
      );
      (totalBid, bidAddr) = takeCreate2(salt);
    }
    uint256 bidderRefund;
    uint128 topBidCached;
    uint256 actualBid = Math.min(_bid, totalBid);
    require(actualBid > 0, "You bid nothing");
    if(actualBid < basePrice){
      TransferETHLib.transferETH(_bidder, actualBid, factory.WETH_ADDRESS());
      return bidAddr;
    }
    if(topBidder != address(0)) {
      require(actualBid <= topBid, "You may be the highest bidder");
      bidderRefund = totalBid;
      topBidCached = topBid;
    } else {
      bidderRefund = totalBid - actualBid;
      topBidCached = topBid;
      topBidder = _bidder;
      topBid = uint128(actualBid);
    }
    TransferETHLib.transferETH(_bidder, bidderRefund, factory.WETH_ADDRESS());
    emit BidRevealed(
      topBidder, // old val
      topBidCached, // old val
      _bidder, // new val
      actualBid // new val
    );
  }

  function lateReveal(address _bidder, uint256 _bid, bytes32 _subSalt) 
  external nonReentrant returns(address bidAddr) {
    uint256 totalBid;
    if (revealStartTime + revealDuration > block.timestamp) {
      revert RevealInProgress();
    }
    (bytes32 salt, ) = getBidDepositAddr(_bidder, _bid, _subSalt);
    (totalBid, bidAddr) = takeCreate2(salt);
    require(totalBid > 0, "No ETH");
    (uint256 slashed) = _getSlashAmt(Math.min(_bid, totalBid));
    unchecked {
      TransferETHLib.transferETH(owner, slashed, factory.WETH_ADDRESS());
      TransferETHLib.transferETH(_bidder, totalBid - slashed, factory.WETH_ADDRESS());
    }
    emit Slashed(_bidder, totalBid, slashed);
  }

  function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
    /// @solidity memory-safe-assembly
    assembly {
      // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
      if mul(y, gt(x, div(not(0), y))) {
        mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
        revert(0x1c, 0x04)
      }
      z := div(mul(x, y), WAD)
    }
  }
  function _getSlashAmt(uint256 _bid) internal view returns (uint256 slashAmt) {
    unchecked {
      if(_bid > topBid) {
        slashAmt = _bid - topBid + mulWad(topBid, SLASH_AMT);
      }
    }
  }

  function ownerClaimNoBidder() public returns(bool){
    if (revealStartTime + revealDuration > block.timestamp) revert RevealNotOver();
    if(topBid == 0) {
      transferNFT(address(this), owner);
      finalizeFac();
      emit ClaimNoBidder();
      return true;
    }
    return false;
  }
  function claimWin() external nonReentrant {
    isClaimed = true;
    if(ownerClaimNoBidder()) return;
    transferNFT(address(this), topBidder);
    uint256 paidBid = topBid;
    TransferETHLib.transferETH(owner, paidBid, factory.WETH_ADDRESS());
    finalizeFac();
    emit WinClaimed(topBidder, paidBid);
  }

  /*╔═══════════════════════╗
    ║       UTILITIES       ║
    ╚═══════════════════════╝*/
  function takeCreate2(bytes32 _salt) internal returns(uint256 totalBid, address bidAddr) {
    uint256 balBefore = address(this).balance;
    assembly {
      mstore(0x00, BID_EXTRACTOR_CODE)
      bidAddr := create2(
        0,
        BID_EXTRACTOR_CODE_OFFSET,
        BID_EXTRACTOR_CODE_SIZE,
        _salt
      )
    }
    totalBid = address(this).balance - balBefore;
  }
  /*╔═══════════════════════╗
    ║    GETTER FUNCTION    ║
    ╚═══════════════════════╝*/
  function getBidDepositAddr(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt
  ) public view returns (bytes32 salt, address depositAddr) {
    assembly {
      // compute the initcode hash
      mstore(0x00, BID_EXTRACTOR_CODE)
      let bidExtractorInitHash := keccak256(
        BID_EXTRACTOR_CODE_OFFSET,
        BID_EXTRACTOR_CODE_SIZE
      )
      let freeMem := mload(0x40)

      // compute the actual create2 salt
      mstore(freeMem, _bidder)
      mstore(add(freeMem, 0x20), _bid)
      mstore(add(freeMem, 0x40), _subSalt)
      salt := keccak256(freeMem, 0x60)

      // predict create2 address
      mstore(add(freeMem, 0x14), address())
      mstore(freeMem, 0xff)
      mstore(add(freeMem, 0x34), salt)
      mstore(add(freeMem, 0x54), bidExtractorInitHash)

      depositAddr := keccak256(add(freeMem, 0x1f), 0x55)
    }
  }

  function getRemainingBidTime() public view returns(uint256) {
    return bidEndTime > block.timestamp ? bidEndTime - block.timestamp : 0;
  }
  function getRemainingRevealTime() public view returns(uint256) {
    if(revealStartTime <= 0) {
      return 0;
    }
    if(revealStartTime + revealDuration > block.timestamp){
      return revealStartTime + revealDuration - block.timestamp;
    }
    return 0;
  }

  function getAuctionInfo() external view
  returns (address, uint256, uint256, uint256, uint256, uint256, address, uint256, bool) {
    return (
      owner,
      basePrice,
      revealDuration,
      getRemainingBidTime(),
      getRemainingRevealTime(),
      revealBlockNum,
      topBidder,
      topBid,
      isClaimed
    );
  }

  // Edge case: user reveal and still send ether to create2 contract, it will depend
  function isFirstOrHighest(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt
  ) external view returns(bool) {
    if(topBid == 0) {
      return true;
    }
    uint256 bidPrice = getEstimatedBidPrice(_bidder, _bid, _subSalt);
    if(bidPrice <= topBid && bidPrice > 0) {
      return true;
    }
    return false;
  }
  // Edge case: After user reveal, always come to 0, but sending ether to create2 contract, it will depends
  function getEstimatedBidPrice(
    address _bidder,
    uint256 _bid,
    bytes32 _subSalt
  ) public view returns(uint256) {
    (, address depositAddr) = getBidDepositAddr(
      _bidder,
      _bid,
      _subSalt
    );
    return Math.min(_bid, address(depositAddr).balance);
  }
}
