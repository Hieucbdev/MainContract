// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import { TransferETHLib } from "../utils/TransferETHLib.sol";
// import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "../utils/Ownable.sol";
// import { IAuctionFactory } from "../IAuctionFactory.sol";

// // Save tạm
// contract SaveOld is Initializable, Ownable, ReentrancyGuard {
//   IAuctionFactory public factory;
//   address[] public NFTContractAddress;
//   uint256[] public tokenId;
  
//   uint256 public basePrice;
//   uint256 public revealEndTime;
//   uint256 public bidEndTime;
//   address public paymentToken;

//   uint256 public bidStep;
//   mapping(uint => address) public bidders;

//   mapping(address => bytes32) public myPriceHash;
//   mapping(address => uint256) public myToken;
//   mapping(address => uint256) public myRealPrice;
//   uint256 currentBid;
//   address currentBidder;
//   bool public isClaimed;
//   bool public isCanceled;

//   /*╔═══════════════════════╗
//     ║        EVENTS         ║
//     ╚═══════════════════════╝*/
//   event AuctionBid(
//     address nftBidder,
//     uint256 bidPrice,
//     bytes32 priceHash
//   );
//   event BidEdit(
//     address nftBidder,
//     uint256 bidPrice,
//     bytes32 priceHash
//   );
//   event BidRevealed(
//     address indexed topBidder,
//     uint256 topBid
//   );
//   event AuctionCancelled(address nftSeller);
//   event WinClaimed(address indexed winner, uint256 paidBid);
//   event Slashed(address indexed bidder, uint256 paidBid, uint256 slashed);

//   receive() external payable {}

//   /*╔═══════════════════════╗
//     ║      CONSTRUCTOR      ║
//     ╚═══════════════════════╝*/
//   function initialize(
//     address operator,
//     address _factory,
//     address[] memory _NFTContractAddress,
//     uint[] memory _tokenId,
//     IAuctionFactory.SealedBidV2Params memory params
//   ) external initializer {
//     _setOwner(operator);
//     factory = IAuctionFactory(_factory);
//     NFTContractAddress = _NFTContractAddress;
//     tokenId = _tokenId;
//     (uint256 mininumBidDuration, uint256 minimumRevealDuration,) = factory.vickreyAdminParams();
//     basePrice = params.basePrice;
//     require(params.bidDuration > mininumBidDuration, "Bid duration too small");
//     require(params.revealDuration > minimumRevealDuration, "Reveal duration too small");
//     bidEndTime = block.timestamp + params.bidDuration;
//     revealEndTime = bidEndTime + params.revealDuration + 10;
//     paymentToken = params.paymentToken;
//   }
//   /*╔══════════════════╗
//     ║       BID        ║
//     ╚══════════════════╝*/
//   function _makeBid(uint256 _bidPrice, bytes32 priceHash) internal {
//     require(_bidPrice > basePrice, "Bid price too low");
//     require(block.timestamp <= bidEndTime, "Auction has ended");
//     require(!isCanceled, "Auction has canceled");
//     if(paymentToken != address(0)){
//       _payout(_msgSender(), address(this), _bidPrice);
//     }
//     myPriceHash[msg.sender] = priceHash;
//     myToken[msg.sender] += _bidPrice;
//     bidStep++;
//     bidders[bidStep] = msg.sender;
//     emit AuctionBid(_msgSender(), _bidPrice, priceHash);
//   }
//   function makeBid(uint256 _bidPrice, bytes32 priceHash) external payable nonReentrant {
//     require(_msgSender() != owner(), "Auctioneer cannot bid");
//     if(paymentToken == address(0)){
//       _makeBid(msg.value, priceHash);
//     } else {
//       _makeBid(_bidPrice, priceHash);
//     }
//   }

//   // K rõ có nên ký không, ở đây nó front run cái priceHash thì sao
//   function _editBid(uint256 _bidPrice, bytes32 priceHash) internal {
//     require(block.timestamp <= bidEndTime, "Auction has ended");
//     require(myToken[msg.sender] > basePrice, "You haven't bidded");
//     if(paymentToken != address(0) && _bidPrice > 0){
//       _payout(_msgSender(), address(this), _bidPrice);
//     }
//     myPriceHash[msg.sender] = priceHash;
//     myToken[msg.sender] += _bidPrice;
//     emit BidEdit(_msgSender(), _bidPrice, priceHash);
//   }
//   function editBid(uint256 _bidPrice, bytes32 priceHash) external payable nonReentrant {
//     require(_msgSender() != owner(), "Auctioneer cannot edit");
//     if(paymentToken == address(0)){
//       _editBid(msg.value, priceHash);
//     } else {
//       _editBid(_bidPrice, priceHash);
//     }
//   }
  
//   function cancelAuction() external nonReentrant onlyOwner {
//     require(
//       bidStep == 0 || (currentBidder == address(0) && block.timestamp > revealEndTime),
//       "Cannot cancel ongoing auction"
//     );
//     isCanceled = true;
//     for(uint256 i = 0; i < NFTContractAddress.length; i++) {
//       IERC721(NFTContractAddress[i]).safeTransferFrom(
//         address(this),
//         _msgSender(),
//         tokenId[i]
//       );
//     }
//     IAuctionFactory(factory).finalizeAuctionInFactory(8);
//     emit AuctionCancelled(_msgSender());
//   }

//   /*╔══════════════════════╗
//     ║       REVEEAL        ║
//     ╚══════════════════════╝*/
//   function reveal(
//     uint256 price,
//     bytes32 salt
//   ) external nonReentrant {
//     require(block.timestamp > bidEndTime && block.timestamp <= revealEndTime, "Auction not ended");
//     require(
//       myPriceHash[msg.sender] == keccak256(abi.encodePacked(price, salt)), 
//       "Price hash invalid"
//     );
//     require(myRealPrice[msg.sender] == 0, "Already reveal");
//     if(price > myToken[msg.sender]){
//       sendTokenFromThisContractTo(msg.sender, price);
//     }
//     myRealPrice[msg.sender] = price;
//     if(price > currentBid) {
//       sendTokenFromThisContractTo(currentBidder, myToken[currentBidder]);
//       currentBid = price;
//       currentBidder = msg.sender;
//       sendTokenFromThisContractTo(msg.sender, myToken[msg.sender] - price);
//     } else {
//       sendTokenFromThisContractTo(msg.sender, myToken[msg.sender]);
//     }
//     emit BidRevealed(
//       currentBidder,
//       currentBid
//     );
//   }

//   function lateReveal(uint256 price, bytes32 salt) external {
//     require(block.timestamp > revealEndTime, "Auction in reveal time");
//     require(
//       myPriceHash[msg.sender] == keccak256(abi.encodePacked(price, salt)), 
//       "Price hash invalid"
//     );
//     require(myRealPrice[msg.sender] == 0, "Already reveal");
//     if(price > myToken[msg.sender]){
//       sendTokenFromThisContractTo(msg.sender, price);
//     }
//     myRealPrice[msg.sender] = price;
//     if(currentBid == 0){
//       sendTokenFromThisContractTo(owner(), price - basePrice);
//       sendTokenFromThisContractTo(msg.sender, myToken[msg.sender] - price + basePrice);
//     } else if(price > currentBid) {
//       sendTokenFromThisContractTo(owner(), price - currentBid);
//       sendTokenFromThisContractTo(msg.sender, myToken[msg.sender] - price + currentBid);
//     } else {
//       sendTokenFromThisContractTo(msg.sender, myToken[msg.sender]);
//     }
//     emit Slashed(msg.sender, price, price - currentBid);
//   }

//   function claimWin() external nonReentrant {
//     isClaimed = true;
//     require(bidStep > 0, "No bids");
//     for(uint256 i = 0; i < NFTContractAddress.length; i++) {
//       IERC721(NFTContractAddress[i]).safeTransferFrom(
//         address(this),
//         currentBidder,
//         tokenId[i]
//       );
//     }
//     sendTokenFromThisContractTo(owner(), myRealPrice[currentBidder]);
//     factory.finalizeAuctionInFactory(8);
//     emit WinClaimed(currentBidder, currentBid);
//   }
//   /*  ╔═════════════════════════╗
//       ║        UTILITIES        ║
//       ╚═════════════════════════╝ */  
//   function getRemainingBidTime() public view returns(uint256) {
//     return bidEndTime > block.timestamp ? bidEndTime - block.timestamp : 0;
//   }
//   function getRemainingRevealTime() public view returns(uint256) {
//     if(bidEndTime > block.timestamp || revealEndTime < block.timestamp){
//       return 0;
//     }
//     return revealEndTime - block.timestamp;
//   }
//   function getAuctionInfo() external view
//   returns (address, address[] memory, uint256[] memory, uint256, uint256, uint256, address, 
//   uint256, uint256, address, bool, bool) 
//   {
//     return (
//       owner(),
//       NFTContractAddress,
//       tokenId, 
//       basePrice,
//       getRemainingBidTime(),
//       getRemainingRevealTime(),
//       paymentToken,
//       bidStep,
//       currentBid,
//       currentBidder,
//       isClaimed,
//       isCanceled
//     );
//   }
//   function _payout(
//     address _sender,
//     address _recipient,
//     uint256 _amount
//   ) internal {
//     if(_sender == address(this)){
//       IERC20(paymentToken).transfer(_recipient, _amount);
//     } else {
//       IERC20(paymentToken).transferFrom(_sender, _recipient, _amount);
//     }
//   }
//   function sendTokenFromThisContractTo(address to, uint256 amount) internal {
//     if(amount > 0) {
//       if(paymentToken == address(0)){
//         TransferETHLib.transferETH(to, amount, IAuctionFactory(factory).WETH_ADDRESS());
//       } else {
//         _payout(address(this), to, amount);
//       }
//     }
//   }
// }
