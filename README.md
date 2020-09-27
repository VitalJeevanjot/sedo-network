![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601198241/sedo-network%20testing/sedo-network.png)


Sedo Network is a service that will let you sell and buy **any** domains registered anywhere through ethereum blockchain. The service plays a trusless intermediary role between seller and buyer.




> **With the power of oracles, We can finally conclude agreements between multiple parties on the blockchain from internet as a source of truth (Trusted sources / APIs) with the power of [Chainlink Tools](https://chain.link/)**

-----

# What's in this repository:

This repository contains **Smart Contracts as Backend** and **Backend Api**

### Smart contracts as backend:
#### 2 Versions: Both contains 3 smart contracts:

[**governance.sol**](https://github.com/genievot/sedo-network/blob/master/Remix%20version/Governance.sol)

[**do-escrow.sol**](https://github.com/genievot/sedo-network/blob/master/Remix%20version/do-excrow.sol)

[**VRFTXT.sol**](https://github.com/genievot/sedo-network/blob/master/Remix%20version/VRFTXT.sol)


- **Remix editor version:** It imports contracts and interfaces from github raw files.

- **Npm version:** This imports files with npm as node modules.


### Backend Api:

**Backend api have 2 endpoints:**

- **Whois** `/whois/<tld>` It will Returns public emails registered with domain with keccak256 version. For example if your email is just like mine. Then you will get something like...

`cac55ec6206f4d48a787103be5bd32f7fbb6ae0ef5a0704b33e90fc8790206c4`

**Make sure your whois guard turned off and you are registered with your email at domain's registrar.** 

You can see what your email says here https://emn178.github.io/online-tools/keccak_256.html

- **TXT Record** `/auth?domain=<tld>` It reads all the Txt records from your domain name.
**Make sure there exist no other TXT record when you test this repository with the domain that you like to put on chain**

-----

# Testing Sedo-Network

Testing can be done in different ways of this repository, Either [Open zeppelin](https://openzeppelin.com/contracts/) **,** [Truffle](http://trufflesuite.com/) **or** [Remix editor](https://remix.ethereum.org/)


## For Demonstration purposes we will use Remix Editor with Kovan Testnet with own chainlink node for handling custom jobs: 

### Governance.sol
- Let's first deploy `Governance.sol` smart contract on remix editor

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601191823/sedo-network%20testing/Screenshot_2020-09-27_125944.png)

- Now we need **client** (do-escrow.sol) and **randomness**(VRFTXT.sol) to register so Deploy them with governance deployed contract address...

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601192193/sedo-network%20testing/Screenshot_2020-09-27_130458.png)

- After deploying, Register them with Governance contract.

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601192194/sedo-network%20testing/Screenshot_2020-09-27_130612.png)


**Make sure to send some [Testnet Link Tokens](https://kovan.chain.link/) to your smart contracts, do-escrow and VRFTXT**
### Do-Escrow.sol

- Once All three smart contracts are set, **Lets Register our first domain** with putDomain function.

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601192567/sedo-network%20testing/Screenshot_2020-09-27_131233.png)

I am using `keybase.us` which is my domain (Whois guard turned off) and also i am making it `on Sale` For only `100000 wei` fake ETH.

- After the Transaction, Wait for sometime before `VRFTXT.sol` Generates the random TXT record for you to put it into your domain.

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601193231/sedo-network%20testing/Screenshot_2020-09-27_132336.png)

- Please call `entity` with your domain name again and Once you have **TXT Value** Just add it into your domain and Remove any other *TXT* Record either from Email service or Domain.

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601193527/sedo-network%20testing/Screenshot_2020-09-27_132807.png)

I am using Namecheap, You can check your domain registrar method to add TXT record on root domain (tld)

- https://api.blockin.network/auth?domain=keybase.us  This endpoint returns the TXT record you have for your domain (Using backend api service, I have uploaded on repo (read above)), Just change keybase.us to your own tld before doing `verification` from smart contract.

-  Once done, Pass domain as url parameter for `verifyDomain` function, Like this `domain=<your_tld>`

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601193881/sedo-network%20testing/Screenshot_2020-09-27_133427.png)

This will check the domain TXT record by calling api with chainlink oracle and match with what's created and stored in smart contract storage for that domain.

- Please wait for sometime to let the chainlink node handle this request for you...
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601194804/sedo-network%20testing/Screenshot_2020-09-27_134849.png)

- After some wait, Please call `entity` again with your domain, And you can see your domain is verified

![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601195003/sedo-network%20testing/Screenshot_2020-09-27_135303.png)

#### It's time to test BUY Domain

- From editor change your account to someone else and run `buyDomain` function with `domain_name` , `email_address` (which will use to scan user) and **`value`** 
The value needs to be exact same as the seller wants to sell this for, call `entity` to know the amount...
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601195743/sedo-network%20testing/Screenshot_2020-09-27_140502.png)

Fill the values
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601195409/sedo-network%20testing/Screenshot_2020-09-27_135950.png)
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601195829/sedo-network%20testing/Screenshot_2020-09-27_140627.png)

Click on buy domain

#### Now release of funds

> The funds can be only released if you trasnfer your domain to the right user and if Whois scan return user email that matches the email added by buyer

- Type the domain (if you are current owner (registered on chain)) and click `releaseFunds`
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601196061/sedo-network%20testing/Screenshot_2020-09-27_141041.png)

- It will do whois scan  and get the keccak256 version of registered user email address using https://api.blockin.network/whois/keybase.us change keybase.us to your tld to verify (online tool link given above)
![]https://res.cloudinary.com/dpnrocxf9/image/upload/v1601196493/sedo-network%20testing/Screenshot_2020-09-27_141733.png
The job will be completed by chain link node
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601196556/sedo-network%20testing/Screenshot_2020-09-27_141900.png)

- After successfull verification, It will run further states, to reset old user and add new user, transfer the money to old user etc.

### VRFTXT.sol

This can also holds TXT records for domains and Domains for TXT records, If someone wants to find the values.
![](https://res.cloudinary.com/dpnrocxf9/image/upload/v1601196828/sedo-network%20testing/Screenshot_2020-09-27_142331.png)


-----

# Using Npm (Open zeppelin, Truffle)

- The contracts can be deployed easily and what to deploy and how to assign can be seen above. You can create a script that can do that for you.
- In this Directory https://github.com/genievot/sedo-network/tree/master/app/src You can check scripts `eth-send` and `link-send` To transfer Ethereum and Link tokens to any address respectively (Have to change target address inside the script)
- You will need `secrets.json` File inside `app` directory 
```
{
    "mnemonic": "<private_key_or_seed>",
    "url": "https://kovan.infura.io/v3/<project_id>",
    "endpoint": "localhost:8545"
}
```

-----
The project is incomplete and requires more features to be add on and audit before moving to production.  So it is recommended not to use it with real money or involve any real money in to this. For any further assistance, Please contact me on my discord **Genievot#6561**
