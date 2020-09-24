pragma solidity ^0.6.0;

import "./VRFConsumerBase.sol";
import {client_interface} from "./interfaces/client_interface.sol";
import {governance_interface} from "./interfaces/governance_interface.sol";

contract TXTRandomness is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;

    mapping(string => uint256) public TXT_For_Domain;
    mapping(bytes32 => uint256) public requestIds;

    governance_interface public governance;

    constructor(address _governance)
        public
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088 // LINK Token
        )
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10**18; // 0.1 LINK

        governance = governance_interface(_governance);
    }

    function getRandom(uint256 domain) {
        require(
            LINK.balanceOf(address(this)) > fee,
            "Not enough LINK - fill contract with faucet"
        );
        bytes32 _requestId = requestRandomness(keyHash, fee, now); // using block time as seed to avoid another variable...
        requestIds[_requestId] = domain;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        string domain = requestIds[requestId];
        TXT_For_Domain[domain] = randomness;

        client_interface(governance.client()).fulfill_random(randomness);
    }
}
