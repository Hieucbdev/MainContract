// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ICharacterWalletRegistry.sol";
import "./Constants.sol";

contract CNFT is ERC721, Constants {
  uint256 public counter;

  constructor() ERC721("Main character", "CNFT") { }

  function safeMint(bool createWallet, uint256 salt, bytes calldata initData) public returns(address) {
    require(balanceOf(msg.sender) <= 5, "Too many wallets");
    uint256 tokenId = counter;
    counter++;
    _safeMint(msg.sender, tokenId);
    if(createWallet){
      return IERC6551Registry(ERC6551RegistryAddress).createAccount(
        ERC6551TokenBoundAddress, 
        chainId,
        address(this),
        tokenId,
        salt,
        initData
      );
    }
    return address(0);
  }

  function burn(uint tokenId) public {
    require(ownerOf(tokenId) == msg.sender, "Unauthorized");
    super._burn(tokenId);
  }
}