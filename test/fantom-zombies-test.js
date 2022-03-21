const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const {
  abi,
} = require("../artifacts/contracts/FantomZombies.sol/FantomZombies.json");

describe("FantomZombies", function () {
  it("Should return if is whitelist sale when deploy contract", async function () {
    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    expect(await fantomZombies.whitelistSale()).to.equal(true);
  });

  it("Should return true if address is already whitelisted", async function () {
    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    const accounts = await ethers.getSigners();
    const contract = new ethers.Contract(
      fantomZombies.address,
      abi,
      accounts[0]
    );

    const tx = await contract.whitelist(accounts[0].address);
    await tx.wait();

    expect(await contract.isWhitelisted(accounts[0].address)).to.equal(true);
  });

  it("Should return true if the balance is 10 after whitelist mint", async function () {
    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    const accounts = await ethers.getSigners();
    const contract = new ethers.Contract(
      fantomZombies.address,
      abi,
      accounts[0]
    );

    const tx = await contract.whitelist(accounts[0].address);
    await tx.wait();

    const quantity = 10;
    const mintPrice = BigNumber.from(await contract.mintPrice());
    const ethMintPrice = await ethers.utils.formatUnits(mintPrice, 18);
    const price = await ethers.utils.parseUnits(
      String(ethMintPrice * quantity),
      18
    );

    const mintTx = await contract.mint(quantity, { value: price });
    await mintTx.wait();

    const balance = await contract.balanceOf(accounts[0].address);
    expect(balance).to.equal(10);
  });

  it("Should return true if the balance is 10 after mint", async function () {
    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    const accounts = await ethers.getSigners();
    const contract = new ethers.Contract(
      fantomZombies.address,
      abi,
      accounts[0]
    );

    const tx = await contract.openSales();
    await tx.wait();

    const quantity = 10;
    const mintPrice = BigNumber.from(await contract.mintPrice());
    const ethMintPrice = await ethers.utils.formatUnits(mintPrice, 18);
    const price = await ethers.utils.parseUnits(
      String(ethMintPrice * quantity),
      18
    );

    const mintTx = await contract.mint(quantity, { value: price });
    await mintTx.wait();

    const balance = await contract.balanceOf(accounts[0].address);
    expect(balance).to.equal(10);
  });

  it("Should return true if the balance is 10 after giveaway", async function () {
    const FantomZombies = await ethers.getContractFactory("FantomZombies");
    const fantomZombies = await FantomZombies.deploy();
    await fantomZombies.deployed();

    const accounts = await ethers.getSigners();
    const contract = new ethers.Contract(
      fantomZombies.address,
      abi,
      accounts[0]
    );

    const tx = await contract.giveaway(accounts[0].address, 10);
    await tx.wait();

    const balance = await contract.balanceOf(accounts[0].address);
    expect(balance).to.equal(10);
  });
});
