
const testVickreyAuction = async () => {
  const abiCoder = new ethers.utils.AbiCoder();
  let triggerCallData = abiCoder.encode(
    ["uint256", "bytes"], 
    [3, abiCoder.encode(["uint256", 'uint256'], [1, 2])]
  );
  console.log("AA::::::", triggerCallData);

  const adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];

  const nftCoreContract = (await hre.ethers.getContractAt('NFTCore', addresses.NFTCore));
  const nftCoreContractInstance = nftCoreContract.connect(userAccount);

  const auctionFactory = await hre.ethers.getContractFactory('AuctionFactory');
  const blockNumber = (await hre.ethers.provider.getBlock("latest")).number + 2;
  const functionData = auctionFactory.interface.encodeFunctionData(
    'innerCreateAuction',
    [userAccount.address, blockNumber],
  );
  console.log("Reveal blocknumber::", blockNumber);
  console.log("Current blocknumber::", (await hre.ethers.provider.getBlock("latest")).number);
  const tx = await nftCoreContractInstance["safeTransferFrom(address,address,uint256,bytes)"](userAccount.address, addresses.VickreyAuctionFactory, 1, functionData);
  await tx.wait();
  
  const auctionFactoryInstance = (await hre.ethers.getContractAt('AuctionFactory', addresses.VickreyAuctionFactory));
  const auctionNum = await auctionFactoryInstance.numberOfAuction();
  const newAuctionAddress = await auctionFactoryInstance.auctionList(auctionNum - BigInt(1));
  console.log("newAuctionAddress::", newAuctionAddress);

  // Dùng ethersjs version 5
  const signer = new ethers.Wallet("0x78a9e6792b45ea79a9faaa9915795992ddf0c82f0e354d6971f7c73fe9b62be7", new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545"));
  const realAuctionInstance = new ethers.Contract(newAuctionAddress, auctionabi.abi, signer);

  const subsalt = keccak256(toUtf8Bytes("Test"));
  const {
    depositAddr: create2Address
  } = await realAuctionInstance.getBidDepositAddr(adminAccount.address, "1000000000000000000", subsalt);
  
  // Send 1 ether vào create2
  const transactionHash = (await adminAccount.sendTransaction({
    to: create2Address,
    value: parseEther("1.0"),
  })).hash;
  console.log("Balance of create2 address now::", await hre.ethers.provider.getBalance(create2Address));

  // Create2 bh sẽ có 2ETH => edit giá miễn là chưa hết hạn
  await adminAccount.sendTransaction({
    to: create2Address,
    value: parseEther("1.0"),
  });
  console.log("Balance of create2 address now::", await hre.ethers.provider.getBalance(create2Address));
  console.log("Current blocknumber::", (await hre.ethers.provider.getBlock("latest")).number);

  await realAuctionInstance.startReveal();
  console.log("Reveal BlockHash::XXXXXXXXXXXX::", (await realAuctionInstance.storedBlockHash()).toString());

  // Reveal proof
  console.log(blockNumber, create2Address);
  const proof = await getProofx(blockNumber, create2Address);
  console.log(proof.header);
  console.log(proof.accountProof);
  await realAuctionInstance.reveal(adminAccount.address, "1000000000000000000", subsalt, "1000000000000000000", proof.header, proof.accountProof, {
    gasLimit: 5000000,
  });
  console.log("Admin can pull::", await realAuctionInstance.pendingPulls(adminAccount.address));
  console.log("User can pull::", await realAuctionInstance.pendingPulls(userAccount.address));
  await realAuctionInstance.claimWin(addresses.NFTCore, 1, {
    gasLimit: 5000000,
  });
  console.log("Admin can pull::", await realAuctionInstance.pendingPulls(adminAccount.address));
  console.log("User can pull::", await realAuctionInstance.pendingPulls(userAccount.address));
  
  console.log("Balance of admin::", await nftCoreContract.balanceOf(adminAccount.address));
  // Ở case này chỉ có 1 người đấu giá
}