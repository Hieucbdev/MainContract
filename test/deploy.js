// npm run deployganacheui

const hre = require("hardhat");
const { upgrades } = require("hardhat");

const addresses = {
  NFTCore: '0x84008e04CB1966Efc365cA00841c9a442675C9Fc',
  ERC20MockContract: '0x2509aC91567F442FD28733D0c6362D0b91D9E3a4',
  WETH: '0xEBb524CAB2DE601818b94C060CF36d79E016A0A9',
  Multicall3: '0x877A60D11e680A2bf2f3336D47663c229238544b',
  VickreyUtilities: '0x9b4D75A8c499ec2c82842831A1523af6c73EB17B',
  DutchAuction721: '0x2Eb1C24Ada49714BA49F002dBDcD4447F7AC0B3E',
  DutchAuction1155: '0x2Eb1C24Ada49714BA49F002dBDcD4447F7AC0B3E',
  EnglishAuction721: '0xB990E196B15f779f379fb2ecDcE623e854F4D0bE',
  EnglishAuction1155: '0xB990E196B15f779f379fb2ecDcE623e854F4D0bE',
  SealedBidAuctionV1721: '0x180B144c68C21A2309FE8d0A2eaaca416c664b6F',
  SealedBidAuctionV11155: '0x180B144c68C21A2309FE8d0A2eaaca416c664b6F',
  SealedBidAuctionV2721: '0x531F1C86cf8485de10031a2fC05884f34667C1Fe',
  SealedBidAuctionV21155: '0x531F1C86cf8485de10031a2fC05884f34667C1Fe',
  VickreyAuction721: '0x531F1C86cf8485de10031a2fC05884f34667C1Fe',
  VickreyAuction1155: '0x531F1C86cf8485de10031a2fC05884f34667C1Fe',
  AuctionFactory: '0xC20853017D693474eb9f73e39464Ab6886974F89',
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

// Ganacheui MainChain:
// {
//   NFTCore: '0xbb592Da8FBc9df7A15063B255Ca9b8C25493a6EC',
//   ERC20MockContract: '0x0273F59F263229Ccc92A972249CFBDc05cfde263',
//   WETH: '0xa776fd7B0e8367643CBDA1e178388410655c1620',
//   Multicall3: '0xb7fa5DfB9afB380F006228A9911e16dCafC7f7F1',
//   VickreyUtilities: '0xC7E247db31c8a49d4643d8D576eD767d2Fcb77B9',
//   DutchAuction721: '0x4dbf08fCdD7a4B4471a5f889833f593EAeF14529',
//   DutchAuction1155: '0x657f25cF4f0845AE17110A662D6Ce6C6FEDC5C18',
//   EnglishAuction721: '0x2509aC91567F442FD28733D0c6362D0b91D9E3a4',
//   EnglishAuction1155: '0xEBb524CAB2DE601818b94C060CF36d79E016A0A9',
//   SealedBidAuctionV1721: '0x9b4D75A8c499ec2c82842831A1523af6c73EB17B',
//   SealedBidAuctionV11155: '0xC5d70CDa68D94fAb3Fbd7Fc693431dF65aD7e7dE',
//   SealedBidAuctionV2721: '0x877A60D11e680A2bf2f3336D47663c229238544b',
//   SealedBidAuctionV21155: '0x180B144c68C21A2309FE8d0A2eaaca416c664b6F',
//   VickreyAuction721: '0xB990E196B15f779f379fb2ecDcE623e854F4D0bE',
//   VickreyAuction1155: '0x2Eb1C24Ada49714BA49F002dBDcD4447F7AC0B3E',
//   AuctionFactory: '0x531F1C86cf8485de10031a2fC05884f34667C1Fe'
// }