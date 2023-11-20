const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ArdManualBridge Tests", function () {

  async function deployContracts() {
    const [owner, account2, account3] = await ethers.getSigners();

    const MockTokenContract = await ethers.getContractFactory("MockToken");
    const MockBridgedTokenContract = await ethers.getContractFactory("MockToken");
    const token = await MockTokenContract.deploy();
    const bridgeToken = await MockBridgedTokenContract.deploy();

    const LockContract = await ethers.getContractFactory(
      "ArdCoinManualBridgeLocker"
    );
    const lock = await LockContract.deploy(await token.getAddress());

    const MintContract = await ethers.getContractFactory(
      "ArdCoinManualBridgeMinter"
    );
    const mint = await MintContract.deploy(await bridgeToken.getAddress());

    await bridgeToken.transferOwnership(await mint.getAddress())

    // APPROVE TOKEN SUPPLY AMOUNT FOR BOTH CHAIN TOKENS
    await token.approve(await lock.getAddress(),ethers.parseEther("90"))
    await bridgeToken.approve(await mint.getAddress(),ethers.parseEther("90"))

    return { token,bridgeToken, mint, lock, owner, account2, account3 };
  }

  describe("Flow Test", function () {

    it("Manual Bridge Flow - Bridging 10 Tokens then Bridging back 10", async function () {
      const { lock,mint,token,bridgeToken,account2 } = await loadFixture(deployContracts);

      // APPROVE TOKEN SUPPLY AMOUNT FOR BOTH CHAIN TOKENS
      await token.connect(account2).approve(await lock.getAddress(),ethers.parseEther("90"))
      await bridgeToken.connect(account2).approve(await mint.getAddress(),ethers.parseEther("90"))

      await token.mint(account2.address,ethers.parseEther("10"))

      // BRIDGE FROM MAIN CHAIN TO ANOTHER CHAIN FLOW
      await lock.lock(account2.address,ethers.parseEther("10"))
      await mint.mint(account2.address,ethers.parseEther("10"))

      expect(await lock.lockBalance()).to.equal(ethers.parseEther("10"));
      expect(await bridgeToken.balanceOf(account2.address)).to.equal(ethers.parseEther("10"));

      // BRIDGE FROM ANOTHER CHAIN TO MAIN CHAIN FLOW
      await mint.burn(account2.address,ethers.parseEther("10"))
      await lock.unlock(account2.address,ethers.parseEther("10"))

      expect(await bridgeToken.balanceOf(account2.address)).to.equal(ethers.parseEther("0"));
      expect(await token.balanceOf(account2.address)).to.equal(ethers.parseEther("10"));
    });

  });

  describe("ArdCoinManualBridgeLocker", function () {

    it("Checking Lock Errors", async function () {
      const { lock,account2 } = await loadFixture(deployContracts);

      await expect(lock.lock(ethers.ZeroAddress,"0")).to.be.revertedWith(`FROM ADDRESS EMPTY`);
      await expect(lock.lock(account2.address,"0")).to.be.revertedWith(`AMOUNT EMPTY`);
    });

    it("Checking Unlock Errors", async function () {
      const { lock,account2 } = await loadFixture(deployContracts);

      await expect(lock.unlock(ethers.ZeroAddress,"0")).to.be.revertedWith(`TO ADDRESS EMPTY`);
      await expect(lock.unlock(account2.address,"0")).to.be.revertedWith(`AMOUNT EMPTY`);
    });


    it("Checking LockSupply", async function () {
      const { lock } = await loadFixture(deployContracts);
      expect(await lock.lockBalance()).to.equal(0);
    });

    it("Checking Token", async function () {
      const { lock,token } = await loadFixture(deployContracts);
      expect(await lock.token()).to.equal(await token.getAddress());
    });


    it("Checking Pause", async function() {
      const { lock } = await loadFixture(deployContracts);

      await lock.pause();
      expect(await lock.paused()).to.equal(true);
      await lock.unpause();
      expect(await lock.paused()).to.equal(false);
    });

    it("Checking LOCK/UNLOCK WhenPaused", async function() {
      const { lock,account2 } = await loadFixture(deployContracts);
      await lock.pause();

      await expect(lock.lock(account2.address,ethers.parseEther("10"))).to.be.revertedWithCustomError(lock,"EnforcedPause")
      await expect(lock.unlock(account2.address,ethers.parseEther("10"))).to.be.revertedWithCustomError(lock,"EnforcedPause")
    });

    it("Checking LOCK OnlyRole Modifier", async function() {
      const { lock,account2 } = await loadFixture(deployContracts);

      await expect(lock.connect(account2).lock(account2.address,ethers.parseEther("10"))).to.be.
        revertedWithCustomError(lock,"AccessControlUnauthorizedAccount").withArgs(account2.address,await lock.LOCK_ROLE());
    });

    it("Checking UNLOCK OnlyRole Modifier", async function() {
      const { lock,account2 } = await loadFixture(deployContracts);

      await expect(lock.connect(account2).unlock(account2.address,ethers.parseEther("10"))).to.be.
        revertedWithCustomError(lock,"AccessControlUnauthorizedAccount").withArgs(account2.address,await lock.UNLOCK_ROLE());
    });

    it("Checking PAUSER OnlyRole Modifier", async function() {
      const { lock,account2 } = await loadFixture(deployContracts);

      await expect(lock.connect(account2).pause()).to.be.
        revertedWithCustomError(lock,"AccessControlUnauthorizedAccount").withArgs(account2.address,await lock.PAUSER_ROLE());
      await expect(lock.connect(account2).unpause()).to.be.
        revertedWithCustomError(lock,"AccessControlUnauthorizedAccount").withArgs(account2.address,await lock.PAUSER_ROLE());
    });

  });

  describe("ArdCoinManualBridgeMinter", function () {

    it("Checking Mint Errors", async function () {
      const { mint,account2 } = await loadFixture(deployContracts);

      await expect(mint.mint(ethers.ZeroAddress,"0")).to.be.revertedWith(`TO ADDRESS EMPTY`);
      await expect(mint.mint(account2.address,"0")).to.be.revertedWith(`AMOUNT EMPTY`);
    });

    it("Checking Burn Errors", async function () {
      const { mint,account2 } = await loadFixture(deployContracts);

      await expect(mint.burn(ethers.ZeroAddress,"0")).to.be.revertedWith(`FROM ADDRESS EMPTY`);
      await expect(mint.burn(account2.address,"0")).to.be.revertedWith(`AMOUNT EMPTY`);
    });


    it("Checking Token", async function () {
      const { mint,bridgeToken } = await loadFixture(deployContracts);
      expect(await mint.token()).to.equal(await bridgeToken.getAddress());
    });


    it("Checking Pause", async function() {
      const { mint } = await loadFixture(deployContracts);

      await mint.pause();
      expect(await mint.paused()).to.equal(true);
      await mint.unpause();
      expect(await mint.paused()).to.equal(false);
    });

    it("Checking MINT/BURN WhenPaused", async function() {
      const { mint,account2 } = await loadFixture(deployContracts);
      await mint.pause();

      await expect(mint.mint(account2.address,ethers.parseEther("10"))).to.be.revertedWithCustomError(mint,"EnforcedPause")
      await expect(mint.burn(account2.address,ethers.parseEther("10"))).to.be.revertedWithCustomError(mint,"EnforcedPause")
    });

    it("Checking MINT OnlyRole Modifier", async function() {
      const { mint,account2 } = await loadFixture(deployContracts);

      await expect(mint.connect(account2).mint(account2.address,ethers.parseEther("10"))).to.be.
        revertedWithCustomError(mint,"AccessControlUnauthorizedAccount").withArgs(account2.address,await mint.MINT_ROLE ());
    });

    it("Checking BURN OnlyRole Modifier", async function() {
      const { mint,account2 } = await loadFixture(deployContracts);

      await expect(mint.connect(account2).burn(account2.address,ethers.parseEther("10"))).to.be.
        revertedWithCustomError(mint,"AccessControlUnauthorizedAccount").withArgs(account2.address,await mint.BURN_ROLE());
    });

    it("Checking PAUSER OnlyRole Modifier", async function() {
      const { mint,account2 } = await loadFixture(deployContracts);

      await expect(mint.connect(account2).pause()).to.be.
        revertedWithCustomError(mint,"AccessControlUnauthorizedAccount").withArgs(account2.address,await mint.PAUSER_ROLE());
      await expect(mint.connect(account2).unpause()).to.be.
        revertedWithCustomError(mint,"AccessControlUnauthorizedAccount").withArgs(account2.address,await mint.PAUSER_ROLE());
    });

  });

});
