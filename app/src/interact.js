// src/index.js
const Web3 = require('web3');

const web3 = new Web3('http://localhost:8545');
const { setupLoader } = require('@openzeppelin/contract-loader');
const loader = setupLoader({ provider: web3 }).web3;

async function main () {

    // Retrieve accounts from the local node
    const accounts = await web3.eth.getAccounts();

    // TODO:
    const address = '0x82591fB3479CDF8eA40F64166F8010ca6669ACe7';
    const do_escrow = loader.fromArtifact('PaymentGateway', address);


    // Owner account = 0xCeC0C5D9509aee8b46Ab017E4cAE3cD88A811f40

    await do_escrow.methods.sendPayment().send({ from: accounts[1], value: web3.utils.toWei('1', 'ether') });

    console.log(await do_escrow.methods.balance().call({ from: accounts[0] }));



}

main();