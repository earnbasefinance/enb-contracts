const { saveAddresses } = require("./utils");
const ENBToken = artifacts.require("ENB");

module.exports = async function (deployer, network) {
  await deployer.deploy(ENBToken);
  await saveAddresses(network, { ENB: ENBToken.address });
};
