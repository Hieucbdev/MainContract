// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import { TransferETHLib } from "./utils/TransferETHLib.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IAuctionFactory.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { VickreyAuction721 } from "./auction/VickreyAuction/VickreyAuction721.sol";
import { VickreyAuction1155 } from "./auction/VickreyAuction/VickreyAuction1155.sol";
import { EnglishAuction721 } from "./auction/EnglishAuction/EnglishAuction721.sol";
import { EnglishAuction1155 } from "./auction/EnglishAuction/EnglishAuction1155.sol";
import { DutchAuction721 } from "./auction/DutchAuction/DutchAuction721.sol";
import { DutchAuction1155 } from "./auction/DutchAuction/DutchAuction1155.sol";
import { SealedBidAuctionV1721 } from "./auction/SealedBidAuctionV1/SealedBidAuctionV1721.sol";
import { SealedBidAuctionV11155 } from "./auction/SealedBidAuctionV1/SealedBidAuctionV11155.sol";
import { SealedBidAuctionV2721 } from "./auction/SealedBidAuctionV2/SealedBidAuctionV2721.sol";
import { SealedBidAuctionV21155 } from "./auction/SealedBidAuctionV2/SealedBidAuctionV21155.sol";

contract AuctionFactory is OwnableUpgradeable, PausableUpgradeable, IAuctionFactory {
  mapping(AuctionType => address) public auctionImplementation;
  mapping(address => bool) public ongoingAuction;

  // Tạm thời chưa cần cái này cho frontend, tương lai frontend cần thì thêm vào
  // mapping(address => EnumerableSet.AddressSet) auctionByUser;
  // mapping(address => EnumerableSet.AddressSet) auctionByCollection;

  VickreyParamsAdmin override public vickreyAdminParams;
  EnglishParamsAdmin override public englishAdminParams;  
  address public WETH_ADDRESS;

  /*╔══════════════════════════════╗
    ║         CONSTRUCTOR          ║
    ╚══════════════════════════════╝*/
  function initialize(
    AuctionType[] memory auctionType,
    address[] memory auctionData, 
    EnglishParamsAdmin memory _englishAdminParams,
    VickreyParamsAdmin memory _vickreyAdminParams,
    address _WETH_ADDRESS
  ) external initializer {
    __Ownable_init();
    __Pausable_init_unchained();
    englishAdminParams = _englishAdminParams;
    vickreyAdminParams = _vickreyAdminParams;
    for(uint i = 0; i < auctionData.length; i++){
      auctionImplementation[auctionType[i]] = auctionData[i];
    }
    WETH_ADDRESS = _WETH_ADDRESS;
  }

  /*╔══════════════════════════════╗
    ║         MAIN LOGIC           ║
    ╚══════════════════════════════╝*/
  function innerCreateAuction(AuctionType, address, bytes memory) external pure {
    revert NotCallable();
  }
  // ERC721
  function onERC721Received(
    address operator,
    address,
    uint256 _tokenId,
    bytes memory _data
  ) external whenNotPaused returns (bytes4) {    
    {
      bytes4 dataSelector;
      assembly {
        dataSelector := mload(add(_data, 0x20))
      }
      if (dataSelector != AuctionFactory.innerCreateAuction.selector)
        revert InvalidReceiveData();
    }
    assembly {
      mstore(add(_data, 0x04), sub(mload(_data), 0x04))
      _data := add(_data, 0x04)
    }
    (AuctionType auctionType, bytes memory auctionData) = abi.decode(_data, (AuctionType, bytes));
    address newAuction = Clones.clone(auctionImplementation[auctionType]);
    address[] memory nftAddresses = new address[](1);
    uint[] memory nftIds = new uint[](1);
    nftAddresses[0] = msg.sender;
    nftIds[0] = _tokenId;
    if(auctionType == AuctionType.ENGLISHAUCTION721) {
      EnglishParams memory creatorParams = abi.decode(auctionData, (EnglishParams));
      EnglishAuction721(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        creatorParams
      );
    } else if(auctionType == AuctionType.VICKREYAUCTION721) {
      VickreyParams memory params = abi.decode(auctionData, (VickreyParams));
      VickreyAuction721(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        params
      );
    } else if(auctionType == AuctionType.DUTCHAUCTION721) {
      DutchParams memory params = abi.decode(auctionData, (DutchParams));
      DutchAuction721(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        params
      );
    } else if(auctionType == AuctionType.SEALEDBIDAUCTIONV1721) {
      VickreyParams memory params = abi.decode(auctionData, (VickreyParams));
      SealedBidAuctionV1721(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        params
      );
    } else if(auctionType == AuctionType.SEALEDBIDAUCTIONV2721) {
      SealedBidV2Params memory params = abi.decode(auctionData, (SealedBidV2Params));
      SealedBidAuctionV2721(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        params
      );
    } else {
      revert InvalidAuctionType();
    }
    ongoingAuction[newAuction] = true;
    emit AuctionCreated(newAuction, uint256(auctionType));
    IERC721(msg.sender).transferFrom(address(this), newAuction, _tokenId);
    return this.onERC721Received.selector;
  }

  function createNewAuction1155(
    AuctionType auctionType, bytes memory auctionData, address operator, 
    address[] memory nftAddresses, uint[] memory nftIds, uint[] memory nftValues
  ) internal returns(address newAuction) {
    newAuction = Clones.clone(auctionImplementation[auctionType]);
    if(auctionType == AuctionType.DUTCHAUCTION1155) {
      DutchParams memory creatorParams = abi.decode(auctionData, (DutchParams));
      DutchAuction1155(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.ENGLISHAUCTION1155) {
      EnglishParams memory creatorParams = abi.decode(auctionData, (EnglishParams));
      EnglishAuction1155(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.VICKREYAUCTION1155) {
      VickreyParams memory creatorParams = abi.decode(auctionData, (VickreyParams));
      VickreyAuction1155(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.SEALEDBIDAUCTIONV11155) {
      VickreyParams memory creatorParams = abi.decode(auctionData, (VickreyParams));
      SealedBidAuctionV11155(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.SEALEDBIDAUCTIONV21155) {
      SealedBidV2Params memory creatorParams = abi.decode(auctionData, (SealedBidV2Params));
      SealedBidAuctionV21155(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else {
      revert InvalidAuctionType();
    }
  }

  // ERC1155
  function onERC1155Received(
    address operator,
    address,
    uint256 id,
    uint256 value,
    bytes memory _data
  ) public whenNotPaused returns (bytes4) {
    {
      bytes4 dataSelector;
      assembly {
        dataSelector := mload(add(_data, 0x20))
      }
      if (dataSelector != AuctionFactory.innerCreateAuction.selector)
        revert InvalidReceiveData();
    }
    assembly {
      mstore(add(_data, 0x04), sub(mload(_data), 0x04))
      _data := add(_data, 0x04)
    }
    (AuctionType auctionType, bytes memory auctionData) = abi.decode(_data, (AuctionType, bytes));
    address[] memory nftAddresses = new address[](1);
    uint[] memory nftIds = new uint[](1);
    uint[] memory nftValues = new uint[](1);
    nftAddresses[0] = msg.sender;
    nftIds[0] = id;
    nftValues[0] = value;
    address newAuction = createNewAuction1155(auctionType, auctionData, operator, nftAddresses, nftIds, nftValues);
    ongoingAuction[newAuction] = true;
    emit AuctionCreated(newAuction, uint256(auctionType));
    IERC1155(msg.sender).safeTransferFrom(address(this), newAuction, id, value, "");

    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address operator,
    address,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory _data
  ) public whenNotPaused returns (bytes4) {
    {
      bytes4 dataSelector;
      assembly {
        dataSelector := mload(add(_data, 0x20))
      }
      if (dataSelector != AuctionFactory.innerCreateAuction.selector)
        revert InvalidReceiveData();
    }
    assembly {
      mstore(add(_data, 0x04), sub(mload(_data), 0x04))
      _data := add(_data, 0x04)
    }
    (AuctionType auctionType, bytes memory auctionData) = abi.decode(_data, (AuctionType, bytes));
    address[] memory nftAddresses = new address[](1);
    nftAddresses[0] = msg.sender;
    address newAuction = createNewAuction1155(auctionType, auctionData, operator, nftAddresses, ids, values);
    ongoingAuction[newAuction] = true;
    emit AuctionCreated(newAuction, uint256(auctionType));
    IERC1155(msg.sender).safeBatchTransferFrom(address(this), newAuction, ids, values, "");

    return this.onERC1155BatchReceived.selector;
  }

  /*╔══════════════════════════════╗
    ║        ADMIN FUNCTION        ║
    ╚══════════════════════════════╝*/
  function withdraw(address token, address receiver) external {
    require(msg.sender == owner(), "Only owner can withdraw");
    if(token == address(0)) {
      TransferETHLib.transferETH(receiver, address(this).balance, WETH_ADDRESS);
    } else {
      IERC20(token).transfer(receiver, IERC20(token).balanceOf(address(this)));
    }
  }
  bool public isLocked;
  function pause() external onlyOwner {
    isLocked = true;
    _pause();
  }
  function unpauseContract() external onlyOwner {
    isLocked = false;
    _unpause();
  }
  function setAuctionImplementation(AuctionType index, address _auctionAddress) external onlyOwner {
    auctionImplementation[index] = _auctionAddress;
  }
  function setEnglishAdminParams(EnglishParamsAdmin memory _englishAdminParams) external onlyOwner {
    englishAdminParams = _englishAdminParams;
  }
  function setVickreyAdminParams(VickreyParamsAdmin memory _vickreyAdminParams) external onlyOwner {
    vickreyAdminParams = _vickreyAdminParams;
  }

  /*╔═════════════════════════════════════════════╗
    ║        FUNCTION FOR AUCTION CONTRACT        ║
    ╚═════════════════════════════════════════════╝*/
  receive() external payable {}
  function finalizeAuctionInFactory(uint256 auctionType) whenNotPaused external {
    require(ongoingAuction[msg.sender], "NOT_ONGOING_AUCTION");
    ongoingAuction[msg.sender] = false;
    emit AuctionFinalized(msg.sender, auctionType);
  }
}