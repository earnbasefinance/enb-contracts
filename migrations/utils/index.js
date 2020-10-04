const fs = require("fs").promises;

const getAddresses = async (network) => {
  const filePath = `./addresses/${network}.json`;
  const json = await fs.readFile(filePath, "utf-8");
  let addresses = {};
  try {
    addresses = JSON.parse(json);
  } catch (e) {
    addresses = {};
  }
  return addresses;
};

const saveAddresses = async (network, newAddresses) => {
  const filePath = `./addresses/${network}.json`;
  const addresses = await getAddresses(network);
  Object.entries(newAddresses).forEach(([key, value]) => {
    if (value) {
      addresses[key] = value;
    }
  });
  return fs.writeFile(filePath, JSON.stringify(addresses, null, 4));
};

module.exports = {
  saveAddresses,
  getAddresses,
};
