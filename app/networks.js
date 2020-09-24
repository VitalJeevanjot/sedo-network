const { url, mnemonic, endpoint } = require('./secrets.json');
const HDWalletProvider = require('@truffle/hdwallet-provider');


module.exports = {
  // Can use anyone..... Check secrets.json
  networks: {
    development: {
      protocol: 'http',
      host: endpoint,
      gas: 2500000,
      gasPrice: 5e9,
      networkId: '1'
    },

    kovan: {
      provider: () => new HDWalletProvider(
        mnemonic, url
      ), networkId: 42,
      gas: 2500000,
      gasPrice: 5000000000,
    }
  },
};
