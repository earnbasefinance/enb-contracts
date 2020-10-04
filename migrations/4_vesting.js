const { saveAddresses, getAddresses } = require("./utils");
const TokenVesting = artifacts.require("TokenVesting");
const StakingFunds = artifacts.require("StakingFunds");

module.exports = async function (deployer, network) {
  const { ENB: ENBAddress } = await getAddresses(network);

  await deployer.deploy(TokenVesting, ENBAddress);
  const InvestorVesting = TokenVesting.address;
  await deployer.deploy(TokenVesting, ENBAddress);
  const TeamVesting = TokenVesting.address;
  await deployer.deploy(StakingFunds);
  await saveAddresses(network, { InvestorVesting, TeamVesting, StakingFunds });
};
