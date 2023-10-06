import hre from "hardhat";

async function main() {
  const [deployer, user1, user2] = await hre.ethers.getSigners();

  const BrandToken = await hre.ethers.getContractFactory("BrandToken");
  const brandToken = await BrandToken.deploy(100000);

  await brandToken.deployed();

  console.log(`Brand token deployed to ${brandToken.address}`);

  console.log("Estimate gas mintBatch ", await brandToken.estimateGas.mintBatch(deployer.address, 2000))

  // await brandToken.mintBatch(deployer.address, 2000)
  // await brandToken.mintBatch(deployer.address, 1000)
  // await brandToken.mintBatch(deployer.address, 1)

  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  await brandToken.mintBatch(deployer.address, 1000)
  
  
  await logBatches();

  await transfer(10000);
  await logBatches();

  // await transfer(1500);
  // await logBatches();

  // await transfer(501);
  // await logBatches();

  // await transfer(501);
  // await logBatches();


  async function logBatches() {
    const lastBatchId = (await brandToken.lastBatchId()).toNumber();
    for (let i = 0; i < lastBatchId; i++) {
      console.log("Batch " + (await brandToken.tokenBatches(i))[0]);
    }
  }

  async function transfer(amount: number) {
    console.log("Transfer: ", amount, " -- Gas Estimate: ", await brandToken.estimateGas.transfer(user1.address, amount));
    await brandToken.transfer(user1.address, amount);
  }
}

main().catch((error) => {
});
