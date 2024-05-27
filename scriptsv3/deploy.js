// npm run deploysepolia
// Nhớ đổi VickreyUtilities dùng đúng network trước

const hre = require("hardhat");
const { upgrades } = require("hardhat");

const addresses = {
  NFTCore: '0x84Ab7Ff55717A95639DC38c3E7E40C5c2d18B4Fd',
  NFT1155Core: '0xfB7E87D1F40716A712b1A8Fc09b3F3F38F38068a',
  ERC20MockContract: '0x4Bd0F909Ba85D52f98f1495fBa75f262A4aDdD40',
  WETH: '0x9f35F3e94896e62c00f2471Ce3566725fd976566',
  Multicall3: '0x2a26c8eAa08C712F3474D7d37d740A5E4e9f38f9',
  VickreyUtilities: '0x02B562D3E0399d3f7909023d5702E9421F4548B2',
  DutchAuction: '0x0256D9606600f46FD97e578F85eE77a166E18541',
  EnglishAuction: '0xB655842adc2Ec116F1FCaDE73b171AFdD9D82b0f',
  SealedBidAuctionV1: '0xA2Ef6A5C24A48f8f88bf2A53C965d6f9245497be',
  SealedBidAuctionV2: '0xa9B5532fBC29a056d3FBD02F122Ca6f943FA1bdF',
  VickreyAuction: '0xebD0324ECaFeF26519FB0b858ab24BD06643a696',
  AuctionFactory: '0x38B59C35b6f7e94A0bE04190Af7d744bff0a869D'
}

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);

  const dutchAuctionInstance = await (await hre.ethers.getContractFactory('DutchAuction')).connect(adminAccount);
  const dutchAuction = await dutchAuctionInstance.deploy();
  await dutchAuction.waitForDeployment();
  addresses.DutchAuction = dutchAuction.target;
  console.log("dutchAuction.target::", addresses.DutchAuction);

  const englishAuctionInstance = await (await hre.ethers.getContractFactory('EnglishAuction')).connect(adminAccount);
  const englishAuction = await englishAuctionInstance.deploy();
  await englishAuction.waitForDeployment();
  addresses.EnglishAuction = englishAuction.target;
  console.log("englishAuction.target::", addresses.EnglishAuction);

  const sealedBidAuctionV1Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV1')).connect(adminAccount);
  const sealedBidAuctionV1 = await sealedBidAuctionV1Instance.deploy();
  await sealedBidAuctionV1.waitForDeployment();
  addresses.SealedBidAuctionV1 = sealedBidAuctionV1.target;
  console.log("sealedBidAuctionV1.target::", addresses.SealedBidAuctionV1);

  const sealedBidAuctionV2Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV2')).connect(adminAccount);
  const sealedBidAuctionV2 = await sealedBidAuctionV2Instance.deploy();
  await sealedBidAuctionV2.waitForDeployment();
  addresses.SealedBidAuctionV2 = sealedBidAuctionV2.target;
  console.log("sealedBidAuctionV2.target::", addresses.SealedBidAuctionV2);

  const vickreyAuctionInstance = await (await hre.ethers.getContractFactory('VickreyAuction')).connect(adminAccount);
  const vickreyAuction = await vickreyAuctionInstance.deploy();
  await vickreyAuction.waitForDeployment();
  addresses.VickreyAuction = vickreyAuction.target;
  console.log("vickreyAuction.target::", addresses.VickreyAuction);

  const auctionFactoryInstance = await (await hre.ethers.getContractFactory('AuctionFactory')).connect(adminAccount);
  let auctionFactory = await upgrades.deployProxy(auctionFactoryInstance, [
    [0, 1, 2, 3, 4],
    [
      addresses.EnglishAuction,
      addresses.VickreyAuction,
      addresses.DutchAuction,
      addresses.SealedBidAuctionV1,
      addresses.SealedBidAuctionV2
    ],
    {
      feePercent: 100, // 1%
      minimumRemainingTime: 100, // second
      bidStepPercent: 500,
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
