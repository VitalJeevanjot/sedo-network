const Web3 = require('web3');

const abi_link = require('./abi/link.json');
const address_link = '0x514910771af9ca656af840dff83e8264ecf986ca';

const unlockedAddress = "0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8";
var userDoingtx;
// --contract address-- TODO:
const recipientAddress = "0xccbD0bF91191AD3c8Df94f87c0e8A437a6B41cFD";
// ----
const { setupLoader } = require('@openzeppelin/contract-loader');


const web3 = new Web3('http://localhost:8545');
const loader = setupLoader({ provider: web3 }).web3;

const chainlink = loader.fromArtifact('ATestnetConsumer', recipientAddress);

const link = new web3.eth.Contract(
    abi_link,
    address_link
);


console.log('0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-')
async function deploy_trasnfer_run () {

    const accounts = await web3.eth.getAccounts();
    userDoingtx = accounts[0]


    console.log(`Operational account balance:`);
    console.log(web3.utils.fromWei(await web3.eth.getBalance(userDoingtx)))
    let unlockedBalance, recipientBalance;
    unlockedBalance = await link.methods.balanceOf(unlockedAddress).call();
    recipientBalance = await link.methods.balanceOf(recipientAddress).call();
    console.log(`Balance of Unlocked address link ${unlockedBalance}`);
    console.log(`Balance of Contract link ${recipientBalance}`);

    await link.methods.transfer(recipientAddress, web3.utils.toWei('1', 'ether')).send({ from: unlockedAddress });

    unlockedBalance = await link.methods.balanceOf(unlockedAddress).call();
    recipientBalance = await link.methods.balanceOf(recipientAddress).call();

    console.log(`Balance of Unlocked address link ${unlockedBalance}`);

    console.log(`Balance of Contract link ${recipientBalance}`);




}

deploy_trasnfer_run();
