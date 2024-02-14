// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Item.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BKHN is ERC1111, Ownable {
  bool public isRedirect;
  string private _baseTokenURI;

  constructor(address _signer) ERC1111("BKHN", "BKHN", 18) {
    signer = _signer;
    _mintFT(msg.sender, 10000 * 10**18);
  }

  function openRedirect() public onlyOwner {
    isRedirect = true;
  }

  function closeRedirect() public onlyOwner {
    isRedirect = false;
  }

  function ftRedirectNFT(uint256 amount) public {
    require(isRedirect, "redirect not open");
    _ft_to_nft(amount);
  }
  function nftRedirectFT(uint256 tokenId) public {
    require(isRedirect, "redirect not open");
    _nft_to_ft(tokenId);
  }

  function _baseURI() internal view virtual returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
  }

  // // Fair launch
  // using Strings for uint256;
  // bytes32 public merkleRoot;
  // mapping(address => bool) public withdrawn;
  // mapping(address => bool) public isFairLaunch;
  // uint256 startTimestamp = 1707534671; // 2024-02-10 11:11:11
  // address public signer;
  // uint256 mintedFairLaunch;
  // mapping(bytes32 => bool) public evidenceUsed;
  // function setStartTimestamp(uint256 _startTimestamp) public onlyOwner {
  //   startTimestamp = _startTimestamp;
  // }
  // function setSigner(address _signer) public onlyOwner {
  //   signer = _signer;
  // }

  // // 5 lần fairlaunch cho 5 người khác nhau, mỗi lần dùng 1 evidence khác nhau
  // function fairLaunch(bytes memory evidence) external{
  //   require(block.timestamp >= startTimestamp, "not start");
  //   require(!isFairLaunch[msg.sender],"claimed");
  //   // require(!Address.isContract(msg.sender), "contract");
  //   require(mintedFairLaunch + 10000 * 10**18 <= 5000 * 10000 * 10**18, "exceed");
  //   require(
  //     !evidenceUsed[keccak256(evidence)] &&
  //       ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(
  //         abi.encodePacked(
  //           msg.sender,
  //           block.chainid
  //         )
  //       )), evidence) == signer,
  //     "invalid evidence"
  //   );
  //   evidenceUsed[keccak256(evidence)] = true;
  //   _mintFT(msg.sender, 10000 * 10**18);
  //   mintedFairLaunch += 10000 * 10**18;
  //   isFairLaunch[msg.sender] = true;
  // }

  // function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
  //   merkleRoot = _merkleRoot;
  // }

  // function claim(uint256 _amount, bytes32[] calldata _proof) external {
  //   address _account = msg.sender;
  //   require(!withdrawn[_account], "withdrawned token.");
    
  //   bytes32 leaf = keccak256(abi.encodePacked(_account, _amount));
  //   require(MerkleProof.verify(_proof, merkleRoot, leaf), "Invalid proof");

  //   withdrawn[_account] = true;

  //   for (uint256 i = 0; i < _amount;i++){
  //     ERC1111._mint(_account);
  //   }
  // }
}