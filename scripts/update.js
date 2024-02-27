// npm run updatesepolia

const hre = require("hardhat");
const { upgrades } = require("hardhat");

const addresses = {
  NFTCore: '0x6314759Cf9e438c363CC432C72e6BF9a91854b03',
  ERC20MockContract: '0x1ED159eCB44AE617196ea782E7AaFDED947c9d9C',
  WETH: '0xCDD188fC3d9493E284b2d5737101BaDe4FC76C16',
  Multicall3: '0x4869312BeA6163f7B501776146E5Bd6d05302C94',
  VickreyUtilities: '0xD2953879a1b17C8cB7Ed7288BE50f2674A443dc3',
  DutchAuction721: '0x999Bb7F586d50c569f2E34082766178B1C16FDb9',
  DutchAuction1155: '0xC986382dA44033F9b00765199270E531346982d3',
  EnglishAuction721: '0x25FED940d3D3C5971e299E5726F12376133332Ed',
  EnglishAuction1155: '0xb630951a30bAA0F7D1050d2F3d4Ca1b6B452F50F',
  SealedBidAuctionV1721: '0xa6799e9fffB8Eb4eaf86a69EBA75FB0fa9A58458',
  SealedBidAuctionV11155: '0x3f72e7ebd73E487022F636C46bA717436a39dE79',
  SealedBidAuctionV2721: '0xf5fB32E89841508Eb5c7cd7182735962E12ad8F9',
  SealedBidAuctionV21155: '0xe9783551ad78465Eab235a2D0F67805E71F9F5AC',
  VickreyAuction721: '0x811D54394921b3a4CC93Ac6198806a6Db28b90c6',
  VickreyAuction1155: '0x9742f67B306856c681EFCd5fDC3CDd09A23Fe8EA',
  AuctionFactory: '0x03f85067EecF885B06e216a4d7435180d45d6256'
};

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);

  const vickreyUtilitiesInstance = await (await hre.ethers.getContractFactory('VickreyUtilities')).connect(adminAccount);
  const vickreyUtilities = await vickreyUtilitiesInstance.deploy();
  await vickreyUtilities.waitForDeployment();
  addresses.VickreyUtilities = vickreyUtilities.target;
  console.log("vickreyUtilities.target::", vickreyUtilities.target);

  const auctionFactoryContract = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  const auctionFactoryContractInstance = auctionFactoryContract.connect(adminAccount);
  var g = await auctionFactoryContractInstance.setVickreyAdminParams({
    mininumBidDuration: 0,
    minimumRevealDuration: 0,
    VICKREY_UTILITIES: vickreyUtilities.target
  });
  console.log("auctionFactory gas used:: ", (await g.wait()).gasUsed.toString());
}
test();