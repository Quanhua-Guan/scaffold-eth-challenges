const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const diceGame = await ethers.getContract("DiceGame", deployer);

  
  await deploy("RiggedRoll", {
   from: deployer,
   args: [diceGame.address],
  //  value: ethers.utils.parseEther("0.2"),
   log: true
  });
  
  const riggedRoll = await ethers.getContract("RiggedRoll", deployer);

  // const ownershipTransaction = await riggedRoll.transferOwnership(deployer);
  console.log("new owner:", deployer);
  console.log("new owner:", await riggedRoll.owner());

};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["RiggedRoll"];
