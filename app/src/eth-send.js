// FOR PUBLIC NETWORK USE METAMASK.. THIS IS ONLY FOR TESTING MAINNET FORKS.
const Web3 = require('web3');
const { url } = require('../secrets.json');


const abi_link = require('./abi/link.json');

const unlockedAddress = "0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8";

var userDoingtx;
// --contract address-- TODO:
const recipientAddress = "0xa757BAe74BE96B0FE84a8585BBf2C05DbD64EC99"; // node admin of chainlink
// ----
const { setupLoader } = require('@openzeppelin/contract-loader');


const web3 = new Web3(url);
const loader = setupLoader({ provider: web3 }).web3;


console.log('0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-')
async function deploy_trasnfer_run () {
    // console.log(await web3.eth.getChainId());
    // console.log(await web3.eth.getId());
    const accounts = await web3.eth.getAccounts();
    userDoingtx = accounts[0]


    web3.eth.sendTransaction({ from: userDoingtx, to: recipientAddress, value: web3.utils.toWei('1.1', 'ether'), gasLimit: 21000, gasPrice: 20000000000 })




}

deploy_trasnfer_run();
