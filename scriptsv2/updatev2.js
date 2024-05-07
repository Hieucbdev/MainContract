// npm run deploysepolia
// Nhớ đổi VickreyUtilities dùng đúng network trước

const hre = require("hardhat");
const { upgrades } = require("hardhat");

const addresses = {
  // NFTCore: '0x6314759Cf9e438c363CC432C72e6BF9a91854b03', // Old
  NFTCore: '0x84Ab7Ff55717A95639DC38c3E7E40C5c2d18B4Fd',
  NFT1155Core: '0xfB7E87D1F40716A712b1A8Fc09b3F3F38F38068a',
  ERC20MockContract: '0x4Bd0F909Ba85D52f98f1495fBa75f262A4aDdD40',
  WETH: '0x9f35F3e94896e62c00f2471Ce3566725fd976566',
  Multicall3: '0x2a26c8eAa08C712F3474D7d37d740A5E4e9f38f9',
  VickreyUtilities: '0x02B562D3E0399d3f7909023d5702E9421F4548B2',
  DutchAuction721: '0xe272341bd306a68C815DCbD817FA274cA1764B6f',
  DutchAuction1155: '0xA0E605207E0A353e6CE04f58b0d11f2860EB31E6',
  EnglishAuction721: '0xB92C099Aed44A81fb3902FE8974456050CDF55D2',
  EnglishAuction1155: '0xD8970d0Bb5D922E8EfF217D52487B2ad1754f7B4',
  SealedBidAuctionV1721: '0xd881B83aAf980C110bA33c3570065b8855d9F693',
  SealedBidAuctionV11155: '0x76A1398cd9E8C4a2b33014c8CdC56fEF01E476BC',
  SealedBidAuctionV2721: '0x07ED877c90c7f26659dc766987Fb550fbDb3004d',
  SealedBidAuctionV21155: '0xD98cd1CAd324bBc70BdD7ef13604674f4e8B9F12',
  VickreyAuction721: '0xE692b3907cf0D733723965d425844DAA45b38706',
  VickreyAuction1155: '0xB3Ba43EE9aD57a424F8ec198CB3610d87E7a5Ec2',
  AuctionFactory: '0xb0f0615efC58c9884df197D01522e62B821f5cCb'
};

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);

  // const nftCoreInstance = await (await hre.ethers.getContractFactory('NFTCore')).connect(adminAccount);
  // const nftCore = await nftCoreInstance.deploy();
  // await nftCore.waitForDeployment();
  // addresses.NFTCore = nftCore.target;
  // console.log("NFTCore.target::", nftCore.target);

  // const nftCoreContract = (await hre.ethers.getContractAt('NFTCore', addresses.NFTCore));
  // const nftCoreContractInstance = nftCoreContract.connect(adminAccount);
  // var g = await nftCoreContractInstance.initialize("TestNamev2", "TestSymbolv2");
  // console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  // console.log("Initialized with name::", await nftCoreContractInstance.name());
  // var g = await nftCoreContractInstance.mintBatch(userAccount.address, 17);  
  // console.log("g2 mint batch gas used:: ", (await g.wait()).gasUsed.toString());
  // console.log("Balance NFT of user1 after minting::", (await nftCoreContractInstance.balanceOf(userAccount.address)).toString());
  // var g = await nftCoreContractInstance.setBaseURI("https://ipfs.io/ipfs/bafybeifwvcrv77f4cjsh4j2kdvxwonlkqbmyjjokwtqrwi4aj4zswbonzq/");  
  // console.log("g3 mint batch gas used:: ", (await g.wait()).gasUsed.toString());

  // const nft1155CoreInstance = await (await hre.ethers.getContractFactory('NFT1155Core')).connect(adminAccount);
  // const nft1155Core = await nft1155CoreInstance.deploy();
  // await nft1155Core.waitForDeployment();
  // addresses.NFT1155Core = nft1155Core.target;
  // console.log("NFT1155Core.target::", nft1155Core.target);

  // const nft11155CoreContract = (await hre.ethers.getContractAt('NFT1155Core', addresses.NFT1155Core));
  // const nft1155CoreContractInstance = nft11155CoreContract.connect(adminAccount);
  // var g = await nft1155CoreContractInstance.initialize("https://arweave.net", "TestSymbol1155V2");
  // console.log("nft1155Core init gas used:: ", (await g.wait()).gasUsed.toString());
  // console.log("Initialized 1155 with symbol::", await nft1155CoreContractInstance.symbol());
  // var g = await nft1155CoreContractInstance.mintBatch(userAccount.address, [1, 2, 3, 4, 5, 6], [50,50,50,50,50,50]);  
  // console.log("g2 mint batch 1155 gas used:: ", (await g.wait()).gasUsed.toString());
  // console.log("Balance NFT 1155 of user1 id 5 after minting::", (await nft1155CoreContractInstance.balanceOf(userAccount.address, 5)).toString());

  // const erc20MockInstance = await (await hre.ethers.getContractFactory('ERC20MockContract')).connect(adminAccount);
  // const erc20Mock = await erc20MockInstance.deploy("TestToken", "TEST");
  // await erc20Mock.waitForDeployment();
  // addresses.ERC20MockContract = erc20Mock.target;
  // console.log("erc20Mock.target::", erc20Mock.target);

  // const WETHInstance = await (await hre.ethers.getContractFactory('WETH')).connect(adminAccount);
  // const WETH = await WETHInstance.deploy();
  // await WETH.waitForDeployment();
  // addresses.WETH = WETH.target;
  // console.log("WETH.target::", WETH.target);

  // const multicall3Instance = await (await hre.ethers.getContractFactory('Multicall3')).connect(adminAccount);
  // const multicall3 = await multicall3Instance.deploy();
  // await multicall3.waitForDeployment();
  // addresses.Multicall3 = multicall3.target;
  // console.log("multicall3.target::", addresses.Multicall3);

  // const vickreyUtilitiesInstance = await (await hre.ethers.getContractFactory('VickreyUtilities')).connect(adminAccount);
  // const vickreyUtilities = await vickreyUtilitiesInstance.deploy();
  // await vickreyUtilities.waitForDeployment();
  // addresses.VickreyUtilities = vickreyUtilities.target;
  // console.log("vickreyUtilities.target::", vickreyUtilities.target);

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

  const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  const auctionFactoryInstance = auctionFactory.connect(adminAccount);
  var g = await auctionFactoryInstance.setAuctionImplementation(4, addresses.DutchAuction721);
  console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  g = await auctionFactoryInstance.setAuctionImplementation(5, addresses.DutchAuction1155);
  console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());

  // const englishAuction721Instance = await (await hre.ethers.getContractFactory('EnglishAuction721')).connect(adminAccount);
  // const englishAuction721 = await englishAuction721Instance.deploy();
  // await englishAuction721.waitForDeployment();
  // addresses.EnglishAuction721 = englishAuction721.target;
  // console.log("englishAuction721.target::", addresses.EnglishAuction721);

  // const englishAuction1155Instance = await (await hre.ethers.getContractFactory('EnglishAuction1155')).connect(adminAccount);
  // const englishAuction1155 = await englishAuction1155Instance.deploy();
  // await englishAuction1155.waitForDeployment();
  // addresses.EnglishAuction1155 = englishAuction1155.target;
  // console.log("englishAuction1155.target::", addresses.EnglishAuction1155);

  // const sealedBidAuctionV1721Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV1721')).connect(adminAccount);
  // const sealedBidAuctionV1721 = await sealedBidAuctionV1721Instance.deploy();
  // await sealedBidAuctionV1721.waitForDeployment();
  // addresses.SealedBidAuctionV1721 = sealedBidAuctionV1721.target;
  // console.log("sealedBidAuctionV1721.target::", addresses.SealedBidAuctionV1721);

  // const sealedBidAuctionV11155Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV11155')).connect(adminAccount);
  // const sealedBidAuctionV11155 = await sealedBidAuctionV11155Instance.deploy();
  // await sealedBidAuctionV11155.waitForDeployment();
  // addresses.SealedBidAuctionV11155 = sealedBidAuctionV11155.target;
  // console.log("sealedBidAuctionV11155.target::", addresses.SealedBidAuctionV11155);

  // const sealedBidAuctionV2721Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV2721')).connect(adminAccount);
  // const sealedBidAuctionV2721 = await sealedBidAuctionV2721Instance.deploy();
  // await sealedBidAuctionV2721.waitForDeployment();
  // addresses.SealedBidAuctionV2721 = sealedBidAuctionV2721.target;
  // console.log("sealedBidAuctionV2721.target::", addresses.SealedBidAuctionV2721);

  // const sealedBidAuctionV21155Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV21155')).connect(adminAccount);
  // const sealedBidAuctionV21155 = await sealedBidAuctionV21155Instance.deploy();
  // await sealedBidAuctionV21155.waitForDeployment();
  // addresses.SealedBidAuctionV21155 = sealedBidAuctionV21155.target;
  // console.log("sealedBidAuctionV21155.target::", addresses.SealedBidAuctionV21155);

  // const vickreyAuction721Instance = await (await hre.ethers.getContractFactory('VickreyAuction721')).connect(adminAccount);
  // const vickreyAuction721 = await vickreyAuction721Instance.deploy();
  // await vickreyAuction721.waitForDeployment();
  // addresses.VickreyAuction721 = vickreyAuction721.target;
  // console.log("vickreyAuction721.target::", addresses.VickreyAuction721);

  // const vickreyAuction1155Instance = await (await hre.ethers.getContractFactory('VickreyAuction1155')).connect(adminAccount);
  // const vickreyAuction1155 = await vickreyAuction1155Instance.deploy();
  // await vickreyAuction1155.waitForDeployment();
  // addresses.VickreyAuction1155 = vickreyAuction1155.target;
  // console.log("vickreyAuction1155.target::", addresses.VickreyAuction1155);

  // const auctionFactoryInstance = await (await hre.ethers.getContractFactory('AuctionFactory')).connect(adminAccount);
  // let auctionFactory = await upgrades.deployProxy(auctionFactoryInstance, [
  //   [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  //   [
  //     addresses.EnglishAuction721,
  //     addresses.EnglishAuction1155,
  //     addresses.VickreyAuction721,
  //     addresses.VickreyAuction1155,
  //     addresses.DutchAuction721,
  //     addresses.DutchAuction1155,
  //     addresses.SealedBidAuctionV1721,
  //     addresses.SealedBidAuctionV11155,
  //     addresses.SealedBidAuctionV2721,
  //     addresses.SealedBidAuctionV21155
  //   ],
  //   {
  //     feePercent: 100, // 1%
  //     minimumRemainingTime: 100, // second
  //     bidStepPercent: 500,
  //   }, 
  //   {
  //     mininumBidDuration: 0,
  //     minimumRevealDuration: 0,
  //     VICKREY_UTILITIES: addresses.VickreyUtilities
  //   },
  //   addresses.WETH
  // ]);

  // await auctionFactory.waitForDeployment();
  // addresses.AuctionFactory = auctionFactory.target;
  // console.log("auctionFactory.target::", addresses.AuctionFactory);

  console.log(addresses);
}
test();
