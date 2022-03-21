const hre = require("hardhat");

async function main() {
  const FantomZombies = await hre.ethers.getContractFactory("FantomZombies");
  const fantomZombies = await FantomZombies.deploy();
  await fantomZombies.deployed();

  console.log("Fantom Zombies deployed at: ", fantomZombies.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
