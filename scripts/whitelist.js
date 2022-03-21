require("dotenv").config();
const hre = require("hardhat");
const FantomZombies = require("../artifacts/contracts/FantomZombies.sol/FantomZombies.json");

const contractAddress = process.env.CONTRACT_ADDRESS;

async function main() {
  const accounts = await hre.ethers.getSigners();
  const contract = new hre.ethers.Contract(
    contractAddress,
    FantomZombies.abi,
    accounts[0]
  );

  if (await contract.isWhitelisted(accounts[0].address)) {
    console.log("Address already whitelist!");
  } else {
    const tx = await contract.whitelist(accounts[0].address);
    await tx.wait();

    console.log("Address is now whitelisted!");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
