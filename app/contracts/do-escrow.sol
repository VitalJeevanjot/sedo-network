// Reusable single domain smart contract...
pragma solidity ^0.6.0;

import "./chainlink_contracts/chainlink/ChainlinkClient.sol";
import {governance_interface} from "./interfaces/governance_interface.sol";
import {randomness_interface} from "./interfaces/randomness_interface.sol";

contract DomainOffering is ChainlinkClient {
    // Require escorw agents
    struct DomainName {
        address Current_Self_Claimed_Owner;
        bool Is_Domain_Verified;
        uint256 TxT_Record;
        bool Is_Domain_On_Sale;
        uint256 Amount_To_Sell_For;
        uint256 onSaleFrom;
    }
    mapping(string => DomainName) public entity_verified; // domain name verified by owner
    mapping(string => DomainName) public entity_not_verified; // domain name not verified

    string api_endpoint_to_check_domain_owner;
    string api_endpoint_to_check_domain_txt;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    uint256 public recentTXTResponse;
    governance_interface public governance;

    // modifier onlyAgent() {
    //     require(msg.sender == Current_Owner);
    //     _;
    // }

// modifier requiredAmountToBuyDomain(string memory domain_name) {
    //     require(msg.value >= Amount_To_Sell_For);
    //     _;
    // }

    constructor(address _governance) public {
        governance = governance_interface(_governance);
        
        setPublicChainlinkToken();
        oracle = 0xA1eaDB935335a9d7a48d8160b4Dc372ff16b39Ac;
        jobId = "a4013f7ddbd849cd9b90445da212b107";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    // function buyDomain(string memory domain_name)
    //     public
    //     requiredDomainAndAmount(domain_name)
    //     payable
    // {
    //     if(domains_registered[domain_name].isVerified) {
    //         revert("Either The Domain Not Registered Or it is not verified...");
    //     }
    //     uint256 amount = msg.value;
    //     domains_paid[msg.sender][domain_name] =
    //         domains_paid[msg.sender][domain_name] +
    //         amount;
    // }

    function putDomain(string memory domain_name, bool onSale, uint256 amount)
        public
    {
        if (onSale == true && amount == 0) {
            revert(
                "1 wei is the minimum amount you can sell for."
            );
        }
        if (onSale == true) {
            entity_not_verified[domain_name].onSaleFrom = now;
        }
        entity_not_verified[domain_name].Current_Self_Claimed_Owner = msg.sender;
        entity_not_verified[domain_name].Is_Domain_On_Sale = onSale;
        entity_not_verified[domain_name].Amount_To_Sell_For = amount;
        
        randomness_interface(governance.randomness()).getRandom(domain_name);

        // ---
    }
    function fulfill_random(uint256 randomness, string calldata domain) external {
        require(msg.sender == governance.randomness(), "please call this function officially.");
        require(randomness > 0, "Randomness not provided");
        entity_not_verified[domain].TxT_Record = randomness;
    }

    function verifyDomain(string memory domain) public returns (bytes32 requestId)  {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        // Set the URL to perform the GET request on
        request.add("get", "https://api.blockin.network/auth");
        request.add("queryParams", domain);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
        
    }
    function fulfill(bytes32 _requestId, uint256 txt_value) public recordChainlinkFulfillment(_requestId)
    {
        recentTXTResponse = txt_value;
    }
    // give suggestion that no other txt record should be present
    // Give popup to check from api if txt value is right before making tx.
    // check all fields are filled before verifying
    // send request id number through vrf as well...
    // emit events for verified and unverified domains
    // Change Owner... ON Change owner make domain non-verified
    // Set custom link fee...
    // Make the link token exchange online with galeto with auto conversion to specified links with paying ethereum.
    // On Change Onwership make the txt record 0
    // Avoid Subdomains
    // Get VRF TXT record from another domain
}
