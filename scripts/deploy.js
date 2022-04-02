const hre = require("hardhat");

async function main() {
  const FantomZombies = await hre.ethers.getContractFactory("FantomZombies");
  const fantomZombies = await FantomZombies.deploy();
  await fantomZombies.deployed();

  const IX32PE = await hre.ethers.getContractFactory("IX32PEVirus");
  const IX32PEVirus = await IX32PE.deploy();
  await IX32PEVirus.deployed();

  await fantomZombies.setVirusAddress(IX32PEVirus.address);
  await IX32PEVirus.setInfectionContract(fantomZombies.address);
  await IX32PEVirus.setApprovalForAll(fantomZombies.address, true);

  console.log("Fantom Zombies deployed at: ", fantomZombies.address);
  console.log("IX32PE Virus deployed at: ", IX32PEVirus.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
