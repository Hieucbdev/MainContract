// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IAuctionFactory {
  /*╔══════════════════════════════╗
    ║      EVENTS AND ERRORS       ║
    ╚══════════════════════════════╝*/
  event AuctionCreated(
    address indexed auction,
    uint256 indexed auctionType
  );
  event AuctionFinalized(
    address indexed auction,
    uint256 indexed auctionType
  );
  error NotCallable();
  error InvalidReceiveData();
  error InvalidAuctionType();

  /*╔════════════════════════════╗
    ║      ENUM AND STRUCT       ║
    ╚════════════════════════════╝*/
  enum AuctionType {
    ENGLISHAUCTION721,
    ENGLISHAUCTION1155,
    VICKREYAUCTION721,
    VICKREYAUCTION1155,
    DUTCHAUCTION721,
    DUTCHAUCTION1155,
    SEALEDBIDAUCTIONV1721,
    SEALEDBIDAUCTIONV11155,
    SEALEDBIDAUCTIONV2721,
    SEALEDBIDAUCTIONV21155,
    OTHERAUCTION1,
    OTHERAUCTION2,
    OTHERAUCTION3,
    OTHERAUCTION4
  }

  struct VickreyParams {
    uint256 basePrice; // default 1 for 1 wei
    uint256 bidDuration; // default 1800 for 30m
    uint256 revealDuration; // default 1800 for 30m
  }
  struct VickreyParamsAdmin {
    uint256 mininumBidDuration; // default 1800 for 30m
    uint256 minimumRevealDuration; // default 1800 for 30m
    address VICKREY_UTILITIES;
  }
  struct EnglishParamsAdmin {
    uint256 minimumRemainingTime; // default 600 for 10p
    uint256 feePercent; // Tiền trả cho người trước đó, nên là 1% = 100
  }
  struct EnglishParams {
    uint256 startingBid; // default 1 for 1 wei
    uint256 bidDuration; 
    uint256 bidStepPercent; // Tiền trả hơn người trước đó, nên là 5%
    address paymentToken;
  }
  struct DutchParams {
    uint256 minimumPrice;
    uint256 startingPrice;
    uint256 numberOfStep;
    uint256 stepDuration;
    address paymentToken;
  }

  struct SealedBidV2Params {
    uint256 basePrice; // default 1 for 1 wei
    uint256 bidDuration; // default 1800 for 30m
    uint256 revealDuration; // default 1800 for 30m
    address paymentToken;
  }

  /*╔═════════════════════╗
    ║      FUNCTIONS      ║
    ╚═════════════════════╝*/
  function finalizeAuctionInFactory(uint256 auctionType) external;
  function isLocked() external view returns (bool);
  function WETH_ADDRESS() external view returns (address);
  function vickreyAdminParams() external view returns(uint256, uint256, address);
  function englishAdminParams() external view returns(uint256, uint256);
}