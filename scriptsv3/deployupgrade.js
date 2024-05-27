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
  DutchAuction: '0xbe5C6cA6B9C47e8A8a6327ADe1498273EEDFEB4b',
  EnglishAuction: '0x875A2BFe7E6f1903f4D64e592AFBe440472B5952',
  SealedBidAuctionV1: '0xCBEd43DE916e78883C59f0544345F8d63F72C167',
  SealedBidAuctionV2: '0xDA3a79EC8bdB14f519125B61DD1706F347585A73',
  VickreyAuction: '0x89bbe91becE86aFc5771E40606fb8620EdF53b64',
  AuctionFactory: '0x38B59C35b6f7e94A0bE04190Af7d744bff0a869D'
};

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);
  
  const auctionFactoryInstance = await (await hre.ethers.getContractFactory('AuctionFactory')).connect(adminAccount);
  let auctionFactory = await upgrades.upgradeProxy(addresses.AuctionFactory, auctionFactoryInstance);

  console.log(auctionFactory);
}
test();
