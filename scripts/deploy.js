// npm run deploysepolia
// Nhớ đổi VickreyUtilities dùng đúng network trước

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

  const nftCoreInstance = await (await hre.ethers.getContractFactory('NFTCore')).connect(adminAccount);
  const nftCore = await nftCoreInstance.deploy();
  await nftCore.waitForDeployment();
  addresses.NFTCore = nftCore.target;
  console.log("NFTCore.target::", nftCore.target);

  const nftCoreContract = (await hre.ethers.getContractAt('NFTCore', addresses.NFTCore));
  const nftCoreContractInstance = nftCoreContract.connect(adminAccount);
  var g = await nftCoreContractInstance.initialize("TestName", "TestSymbol");
  console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  console.log("Initialized with name::", await nftCoreContractInstance.name());
  var g = await nftCoreContractInstance.mintBatch(userAccount.address, 17);  
  console.log("g2 mint batch gas used:: ", (await g.wait()).gasUsed.toString());
  console.log("Balance NFT of user1 after minting::", (await nftCoreContractInstance.balanceOf(userAccount.address)).toString());
  var g = await nftCoreContractInstance.setBaseURI("https://ipfs.io/ipfs/QmRrkC8TqK8mfymFA3cvj8DZ9TNfvdPsNuCWvKaf4ajyW9/");  
  console.log("g3 mint batch gas used:: ", (await g.wait()).gasUsed.toString());

  const erc20MockInstance = await (await hre.ethers.getContractFactory('ERC20MockContract')).connect(adminAccount);
  const erc20Mock = await erc20MockInstance.deploy("TestToken", "TT");
  await erc20Mock.waitForDeployment();
  addresses.ERC20MockContract = erc20Mock.target;
  console.log("erc20Mock.target::", erc20Mock.target);

  const WETHInstance = await (await hre.ethers.getContractFactory('WETH')).connect(adminAccount);
  const WETH = await WETHInstance.deploy();
  await WETH.waitForDeployment();
  addresses.WETH = WETH.target;
  console.log("WETH.target::", WETH.target);

  const multicall3Instance = await (await hre.ethers.getContractFactory('Multicall3')).connect(adminAccount);
  const multicall3 = await multicall3Instance.deploy();
  await multicall3.waitForDeployment();
  addresses.Multicall3 = multicall3.target;
  console.log("multicall3.target::", addresses.Multicall3);

  const vickreyUtilitiesInstance = await (await hre.ethers.getContractFactory('VickreyUtilities')).connect(adminAccount);
  const vickreyUtilities = await vickreyUtilitiesInstance.deploy();
  await vickreyUtilities.waitForDeployment();
  addresses.VickreyUtilities = vickreyUtilities.target;
  console.log("vickreyUtilities.target::", vickreyUtilities.target);

  const dutchAuction721Instance = await (await hre.ethers.getContractFactory('DutchAuction721')).connect(adminAccount);
  const dutchAuction721 = await dutchAuction721Instance.deploy();
  await dutchAuction721.waitForDeployment();
  addresses.DutchAuction721 = dutchAuction721.target;
  console.log("dutchAuction721.target::", addresses.DutchAuction721);

  const dutchAuction1155Instance = await (await hre.ethers.getContractFactory('DutchAuction1155')).connect(adminAccount);
  const dutchAuction1155 = await dutchAuction1155Instance.deploy();
  await dutchAuction1155.waitForDeployment();
  addresses.DutchAuction1155 = dutchAuction1155.target;
  console.log("dutchAuction1155.target::", addresses.DutchAuction1155);

  const englishAuction721Instance = await (await hre.ethers.getContractFactory('EnglishAuction721')).connect(adminAccount);
  const englishAuction721 = await englishAuction721Instance.deploy();
  await englishAuction721.waitForDeployment();
  addresses.EnglishAuction721 = englishAuction721.target;
  console.log("englishAuction721.target::", addresses.EnglishAuction721);

  const englishAuction1155Instance = await (await hre.ethers.getContractFactory('EnglishAuction1155')).connect(adminAccount);
  const englishAuction1155 = await englishAuction1155Instance.deploy();
  await englishAuction1155.waitForDeployment();
  addresses.EnglishAuction1155 = englishAuction1155.target;
  console.log("englishAuction1155.target::", addresses.EnglishAuction1155);

  const sealedBidAuctionV1721Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV1721')).connect(adminAccount);
  const sealedBidAuctionV1721 = await sealedBidAuctionV1721Instance.deploy();
  await sealedBidAuctionV1721.waitForDeployment();
  addresses.SealedBidAuctionV1721 = sealedBidAuctionV1721.target;
  console.log("sealedBidAuctionV1721.target::", addresses.SealedBidAuctionV1721);

  const sealedBidAuctionV11155Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV11155')).connect(adminAccount);
  const sealedBidAuctionV11155 = await sealedBidAuctionV11155Instance.deploy();
  await sealedBidAuctionV11155.waitForDeployment();
  addresses.SealedBidAuctionV11155 = sealedBidAuctionV11155.target;
  console.log("sealedBidAuctionV11155.target::", addresses.SealedBidAuctionV11155);

  const sealedBidAuctionV2721Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV2721')).connect(adminAccount);
  const sealedBidAuctionV2721 = await sealedBidAuctionV2721Instance.deploy();
  await sealedBidAuctionV2721.waitForDeployment();
  addresses.SealedBidAuctionV2721 = sealedBidAuctionV2721.target;
  console.log("sealedBidAuctionV2721.target::", addresses.SealedBidAuctionV2721);

  const sealedBidAuctionV21155Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV21155')).connect(adminAccount);
  const sealedBidAuctionV21155 = await sealedBidAuctionV21155Instance.deploy();
  await sealedBidAuctionV21155.waitForDeployment();
  addresses.SealedBidAuctionV21155 = sealedBidAuctionV21155.target;
  console.log("sealedBidAuctionV21155.target::", addresses.SealedBidAuctionV21155);

  const vickreyAuction721Instance = await (await hre.ethers.getContractFactory('VickreyAuction721')).connect(adminAccount);
  const vickreyAuction721 = await vickreyAuction721Instance.deploy();
  await vickreyAuction721.waitForDeployment();
  addresses.VickreyAuction721 = vickreyAuction721.target;
  console.log("vickreyAuction721.target::", addresses.VickreyAuction721);

  const vickreyAuction1155Instance = await (await hre.ethers.getContractFactory('VickreyAuction1155')).connect(adminAccount);
  const vickreyAuction1155 = await vickreyAuction1155Instance.deploy();
  await vickreyAuction1155.waitForDeployment();
  addresses.VickreyAuction1155 = vickreyAuction1155.target;
  console.log("vickreyAuction1155.target::", addresses.VickreyAuction1155);

  const auctionFactoryInstance = await (await hre.ethers.getContractFactory('AuctionFactory')).connect(adminAccount);
  let auctionFactory = await upgrades.deployProxy(auctionFactoryInstance, [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [
      addresses.EnglishAuction721,
      addresses.EnglishAuction1155,
      addresses.VickreyAuction721,
      addresses.VickreyAuction1155,
      addresses.DutchAuction721,
      addresses.DutchAuction1155,
      addresses.SealedBidAuctionV1721,
      addresses.SealedBidAuctionV11155,
      addresses.SealedBidAuctionV2721,
      addresses.SealedBidAuctionV21155
    ],
    {
      feePercent: 100, // 1%
      minimumRemainingTime: 100, // second
    }, 
    {
      mininumBidDuration: 0,
      minimumRevealDuration: 0,
      VICKREY_UTILITIES: addresses.VickreyUtilities
    },
    addresses.WETH
  ]);
  await auctionFactory.waitForDeployment();
  addresses.AuctionFactory = auctionFactory.target;
  console.log("auctionFactory.target::", addresses.AuctionFactory);

  console.log(addresses);
}
test();

// Sepolia:
// {
//   NFTCore: '0x6314759Cf9e438c363CC432C72e6BF9a91854b03',
//   ERC20MockContract: '0x1ED159eCB44AE617196ea782E7AaFDED947c9d9C',
//   WETH: '0xCDD188fC3d9493E284b2d5737101BaDe4FC76C16',
//   Multicall3: '0x4869312BeA6163f7B501776146E5Bd6d05302C94',
//   VickreyUtilities: '0xD2953879a1b17C8cB7Ed7288BE50f2674A443dc3',
//   DutchAuction721: '0x999Bb7F586d50c569f2E34082766178B1C16FDb9',
//   DutchAuction1155: '0xC986382dA44033F9b00765199270E531346982d3',
//   EnglishAuction721: '0x25FED940d3D3C5971e299E5726F12376133332Ed',
//   EnglishAuction1155: '0xb630951a30bAA0F7D1050d2F3d4Ca1b6B452F50F',
//   SealedBidAuctionV1721: '0xa6799e9fffB8Eb4eaf86a69EBA75FB0fa9A58458',
//   SealedBidAuctionV11155: '0x3f72e7ebd73E487022F636C46bA717436a39dE79',
//   SealedBidAuctionV2721: '0xf5fB32E89841508Eb5c7cd7182735962E12ad8F9',
//   SealedBidAuctionV21155: '0xe9783551ad78465Eab235a2D0F67805E71F9F5AC',
//   VickreyAuction721: '0x811D54394921b3a4CC93Ac6198806a6Db28b90c6',
//   VickreyAuction1155: '0x9742f67B306856c681EFCd5fDC3CDd09A23Fe8EA',
//   AuctionFactory: '0x03f85067EecF885B06e216a4d7435180d45d6256'
// }