// npm run createauction

const hre = require("hardhat");
const { upgrades } = require("hardhat");
const ethers = require("oldethers");
const abiCoder = new ethers.utils.AbiCoder();

const addresses = {
  NFTCore: '0x6314759Cf9e438c363CC432C72e6BF9a91854b03',
  ERC20MockContract: '0x1ED159eCB44AE617196ea782E7AaFDED947c9d9C',
  WETH: '0xCDD188fC3d9493E284b2d5737101BaDe4FC76C16',
  Multicall3: '0x4869312BeA6163f7B501776146E5Bd6d05302C94',
  VickreyUtilities: '0xD2953879a1b17C8cB7Ed7288BE50f2674A443dc3',
  DutchAuction721: '0x89E22EA4FAB17d996bbc5e52F0bb4520b121BD87',
  DutchAuction1155: '0x3a1Ab541FCfEfCadF72d90949b13c960a989a9C1',
  EnglishAuction721: '0xa7935f9492029063576f0B27b8890c5Dd2397BD4',
  EnglishAuction1155: '0x4eC3D5B55e3d82bF3eF00c1dbD139D33f1b936B7',
  SealedBidAuctionV1721: '0x24f6E05F4662359cf1073aFe9f0bECE3D1B75786',
  SealedBidAuctionV11155: '0xa63304C9F1D5206f618E21EA1882Db67AfcbCe7a',
  SealedBidAuctionV2721: '0x8FdCB35FD44d2577Efc7CCeE9056D14f5fd212ef',
  SealedBidAuctionV21155: '0xD63B8705B5730aeB921B9E9C2e2E7B1283f20B49',
  VickreyAuction721: '0xcd630Df58894cE41071C7BaF221EF23E8ed273f4',
  VickreyAuction1155: '0xfD8C936476a7581677f28c25CE5F75a0A89EFAB3',
  AuctionFactory: '0xFD21f209bc31a220630bf68a0E97D0C6AB6A628c'
};

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);

  const nftCoreContract = (await hre.ethers.getContractAt('NFTCore', addresses.NFTCore));
  const nftCoreUser1Contract = nftCoreContract.connect(userAccount);
  const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  
  let englishParams = abiCoder.encode(
    ["uint256", "uint256", "uint256", "address"], 
    [1, 10*24*60*60, 100, "0x0000000000000000000000000000000000000000"] 
  );
  const functionData = auctionFactory.interface.encodeFunctionData(
    'innerCreateAuction',
    [0, englishParams],
  );
  console.log(functionData);
  let g = await nftCoreUser1Contract["safeTransferFrom(address,address,uint256,bytes)"](
    userAccount.address, 
    addresses.AuctionFactory, 
    1, 
    functionData
  );
  console.log("g3 create auction:: ", (await g.wait()).gasUsed.toString());
}
test();