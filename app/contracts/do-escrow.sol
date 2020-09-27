// Reusable single domain smart contract...
pragma solidity ^0.6.0;

import "./chainlink_contracts/chainlink/ChainlinkClient.sol";
import {governance_interface} from "./interfaces/governance_interface.sol";
import {randomness_interface} from "./interfaces/randomness_interface.sol";

contract DomainOffering is ChainlinkClient {
    // Require escorw agents
    struct DomainRecord {
        address payable Current_Self_Claimed_Owner;
        address Current_Buyer;
        bool Is_Domain_Verified;
        uint256 TxT_Record;
        bool Is_Domain_On_Sale;
        uint256 Amount_To_Sell_For;
        uint256 On_Sale_From;
        bool Domain_Locked;// locked if user paid for it
        uint256 Amount_Buyer_Paid_For_It;
        address Amount_Paid_By;
        bool Domain_Sold;
        string Domain_Name;
        string Email_Address_Of_Buyer; // important, require for matching whois and unlocking funds
        
    }
    // mapping(string => DomainRecord) public entity_verified; // domain name verified by owner
    mapping(string => DomainRecord) public entity; // domain name not verified
    // mapping(address => string) public user_entity; // domain registered by user
    mapping(bytes32 => string) public requestIds;
    mapping(bytes32 => address) public usersToWithdraw;
    string api_endpoint_to_check_domain_owner;
    string api_endpoint_to_check_domain_txt;
    
    address private oracle;
    bytes32 private jobIdTxT;
    bytes32 private jobIdWhois;
    uint256 private fee;

    uint256 public recentTXTResponse;
    // string public recentWhoisResponseString;
    governance_interface public governance;
    
    bytes32 public recentWhoisHash;
    bytes32 public recentBuyerEmailHash;
    
    bytes32 public recentTxTRequestId;
    bytes32 public recentWhoisRequestId;
    
    event Domain_Added(address curr_owner, string domain);

    // modifier onlyAgent() {
    //     require(msg.sender == Current_Owner);
    //     _;
    // }


    constructor(address _governance) public {
        governance = governance_interface(_governance);
        
        setPublicChainlinkToken();
        oracle = 0xA1eaDB935335a9d7a48d8160b4Dc372ff16b39Ac;
        jobIdTxT = "a4013f7ddbd849cd9b90445da212b107";
        // jobIdWhois = "1cd34d2fac524a06a8986f70e0a0a026"; // plain get and send job
        // jobIdWhois = "e4cef9fb508243bfa143072372efd403"; // byte32 job
        jobIdWhois = "99433a66f3374ce3aa6b7360bf89efcc"; // NoOp job
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }


    function putDomain(string memory domain_name, bool onSale, uint256 amount)
        public
    {
        require(entity[domain_name].Domain_Locked == false);
        require(entity[domain_name].Current_Self_Claimed_Owner == address(0) || (entity[domain_name].Current_Self_Claimed_Owner == msg.sender && entity[domain_name].Is_Domain_Verified == true)); // TODO: It will have an expiration time as well...
        if (onSale == true && amount == 0) {
            revert(
                "1 wei is the minimum amount you can sell for."
            );
        }
        if (onSale == true) {
            entity[domain_name].On_Sale_From = now;
        }
        entity[domain_name].Domain_Name = domain_name;
        entity[domain_name].Current_Self_Claimed_Owner = msg.sender;
        entity[domain_name].Is_Domain_On_Sale = onSale;
        entity[domain_name].Amount_To_Sell_For = amount;
        entity[domain_name].Domain_Sold = false;
        emit Domain_Added(msg.sender, domain_name);
        randomness_interface(governance.randomness()).getRandom(domain_name);

        // ---
    }
    function fulfill_random(uint256 randomness, string calldata domain) external {
        require(msg.sender == governance.randomness(), "please call this function officially.");
        require(randomness > 0, "Randomness not provided");
        entity[domain].TxT_Record = randomness;
    }

    function verifyDomain(string memory domain) public returns (bytes32 requestId)  {
        // here domain is `domain=<tld>`
        Chainlink.Request memory request = buildChainlinkRequest(jobIdTxT, address(this), this.fulfillTXT.selector);
        // Set the URL to perform the GET request on
        request.add("get", "https://api.blockin.network/auth");
        request.add("queryParams", domain);
        
        // Sends the request
        recentTxTRequestId = sendChainlinkRequestTo(oracle, request, fee);
        return recentTxTRequestId;
        
    }
    function fulfillTXT(bytes32 _requestId, uint256 txt_value) public recordChainlinkFulfillment(_requestId)
    {
        recentTXTResponse = txt_value;
        string memory _domainName = randomness_interface(governance.randomness()).getDomainNameForTXT(txt_value);
        uint256 txt_record_to_match = entity[_domainName].TxT_Record;
        
        require(entity[_domainName].Current_Self_Claimed_Owner != address(0)); // require that so to assure first putdomain() has been called
        require(entity[_domainName].Domain_Locked == false);
        
        if(txt_value == txt_record_to_match) {
            entity[_domainName].Is_Domain_Verified = true;
        }
    }
    
    function buyDomain (string memory domain, string memory email_address) payable public {
        require(entity[domain].Domain_Locked == false);
        require(entity[domain].Is_Domain_On_Sale == true); // require that first pudomain is called and it makes sense...
        require(msg.value == entity[domain].Amount_To_Sell_For);
        entity[domain].Domain_Locked = true;
        entity[domain].Domain_Sold = true;
        entity[domain].Amount_Buyer_Paid_For_It = msg.value;
        entity[domain].Amount_Paid_By = msg.sender;
        entity[domain].Email_Address_Of_Buyer = email_address;
        entity[domain].Current_Buyer = msg.sender;
        
    }
    function releaseFunds(string memory domain) public returns (bytes32 requestId)  {
        // here domain is `domain=<tld>`
        require(entity[domain].Current_Self_Claimed_Owner == msg.sender);
        require(entity[domain].Domain_Locked == true);
        Chainlink.Request memory request = buildChainlinkRequest(jobIdWhois, address(this), this.fulfillWhois.selector);
        // Set the URL to perform the GET request on
        request.add("get", "https://api.blockin.network/whois");
        request.add("extPath", domain);
        bytes32 _requestId = sendChainlinkRequestTo(oracle, request, fee);
        recentWhoisRequestId = _requestId;
        requestIds[_requestId] = domain;
        usersToWithdraw[_requestId] = msg.sender;
        return _requestId;
    }
    function fulfillWhois(bytes32 _requestId, bytes32 whois_email) payable public recordChainlinkFulfillment(_requestId)
    {
        // TO RUN this function required String value from chainlink adapter
        // recentWhoisResponseString = whois_email;
        string memory _domainName = requestIds[_requestId];
        // address payable user = payable(usersToWithdraw[_requestId]);
        string memory email_to_match = entity[_domainName].Email_Address_Of_Buyer;
        
        
        // require(entity[_domainName].Current_Self_Claimed_Owner == user);
        
        recentBuyerEmailHash = bytes32(keccak256(abi.encodePacked(email_to_match)));
        recentWhoisHash = whois_email; // it is already hashed from api...
        if(recentWhoisHash == recentBuyerEmailHash) {
            payable(entity[_domainName].Current_Self_Claimed_Owner).transfer(entity[_domainName].Amount_Buyer_Paid_For_It); // right now this value says no fee but can be modified later...
            entity[_domainName].Current_Self_Claimed_Owner = payable(entity[_domainName].Amount_Paid_By);
            entity[_domainName].Is_Domain_On_Sale = false;
            entity[_domainName].Is_Domain_Verified = false;
            entity[_domainName].Domain_Locked = false;
            entity[_domainName].Amount_To_Sell_For = 0;
            entity[_domainName].Domain_Sold = false;
            entity[_domainName].Current_Buyer = address(0);
            
            // make buyer the owner and
            // make domain sellable again
            
        }
    }
    
    function reGainDomainAccess() internal {
        // If user traded the domain last time outside chain (Make it public)
        // This let user re create TXT record, Re verify domain and claim his own ownership
    }

}

