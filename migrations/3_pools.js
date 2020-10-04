const { saveAddresses, getAddresses } = require("./utils");

const ENBStaking = artifacts.require("ENBGovernance");
const BalLpStaking = artifacts.require("StakingRewards");
const UniLpStaking = artifacts.require("StakingRewards");

module.exports = async function (deployer, network, accounts) {
  const {
    ENB: ENBAddress,
    BalLp: BalLpAddress,
    UniLp: UniLpAddress,
  } = await getAddresses(network);

  let ENBPool, BalLpPool, UniLpPool;

  await deployer.deploy(ENBStaking, ENBAddress, ENBAddress);
  ENBPool = ENBStaking.address;
  await deployer.deploy(BalLpStaking, ENBAddress, BalLpAddress);
  BalLpPool = BalLpStaking.address;
  await deployer.deploy(UniLpStaking, ENBAddress, UniLpAddress);
  UniLpPool = UniLpStaking.address;

  await saveAddresses(network, {
    ENBPool,
    BalLpPool,
    UniLpPool,
  });
};
