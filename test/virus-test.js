const { expect } = require("chai");
const { ethers } = require("hardhat");
const aIX32PE = require("../artifacts/contracts/IX32PEVirus.sol/IX32PEVirus.json");
const aFantomZombies = require("../artifacts/contracts/FantomZombies.sol/FantomZombies.json");

describe("IX32PE", function () {
  it("Airdrop viruses", async function () {
    const IX32PE = await ethers.getContractFactory("IX32PEVirus");
    const ix32pe = await IX32PE.deploy();
    await ix32pe.deployed();

    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    const accounts = await ethers.getSigners();
    const virus = new ethers.Contract(ix32pe.address, aIX32PE.abi, accounts[0]);
    const zombies = new ethers.Contract(
      fantomZombies.address,
      aFantomZombies.abi,
      accounts[0]
    );

    const tx1 = await virus.setInfectionContract(zombies.address);
    await tx1.wait();

    const tx2 = await zombies.setVirusAddress(virus.address);
    await tx2.wait();

    const tx3 = await virus.airdropVirus(accounts[0].address, 5);
    await tx3.wait();

    expect(await virus.balanceOf(accounts[0].address)).to.equal(5);
  });

  it("Infect viruses", async function () {
    const IX32PE = await ethers.getContractFactory("IX32PEVirus");
    const ix32pe = await IX32PE.deploy();
    await ix32pe.deployed();

    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    const accounts = await ethers.getSigners();
    const virus = new ethers.Contract(ix32pe.address, aIX32PE.abi, accounts[0]);
    const zombies = new ethers.Contract(
      fantomZombies.address,
      aFantomZombies.abi,
      accounts[0]
    );

    const tx1 = await virus.setInfectionContract(zombies.address);
    await tx1.wait();

    const tx2 = await zombies.setVirusAddress(virus.address);
    await tx2.wait();

    const tx3 = await virus.airdropVirus(accounts[0].address, 5);
    await tx3.wait();

    const balance = await virus.balanceOf(accounts[0].address);
    console.log(balance);

    const txn = await virus.setApprovalForAll(fantomZombies.address, true);
    await txn.wait();

    if (balance) {
      const tx4 = await zombies.infect(1);
      await tx4.wait();

      expect(await zombies.balanceOf(accounts[0].address)).to.equal(1);
    }
    console.log("bbbbbbbb");
  });
});
