// Reusable single domain smart contract...
pragma solidity ^0.6.0;

import "./chainlink_contracts/chainlink/ChainlinkClient.sol";
import {governance_interface} from "./interfaces/governance_interface.sol";
import {randomness_interface} from "./interfaces/randomness_interface.sol";

contract DomainOffering is ChainlinkClient {
    string public Domain_Name;
    address public Current_Owner; // Also the host for txt record
    bool public Is_Domain_Verified;
    uint256 public TxT_Record;

    bool public Is_Domain_On_Sale;

    uint256 public Amount_To_Sell_For;

    governance_interface public governance;

    modifier onlyAgent() {
        require(msg.sender == Current_Owner);
        _;
    }

    modifier requiredAmountToBuyDomain(string memory domain_name) {
        require(msg.value >= Amount_To_Sell_For);
        _;
    }

    constructor(address _governance, string memory domain_name) public {
        bytes memory domain_name_bytes = bytes(domain_name);
        if (domain_name_bytes.length == 0) {
            revert("Domain Name is required");
        }
        Current_Owner = msg.sender;
        Domain_Name = domain_name;

        governance = governance_interface(_governance);
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

    function putDomainOnSale(uint256 amount)
        public
        onlyAgent()
        returns (bytes32 requestId)
    {
        if (amount == 0) {
            revert(
                "Maybe you want to sell domain for free but atleat put 1 there."
            );
        }
        Amount_To_Sell_For = amount;
        Is_Domain_On_Sale = true;
        if (TxT_Record == 0) {
            // call verify contract
            randomness_interface(governance.randomness()).getRandom(amount);
        }

        // ---
    }
    function fullfill_random(uint256 randomness) external {
        TxT_Record = randomness
    }

    function verifyDomain() public {}

    // Change Owner... ON Change owner make domain non-verified
    // Set custom link fee...
    // Make the link token exchange online with galeto with auto conversion to specified links with paying ethereum.
    // On Change Onwership make the txt record 0
    // Avoid Subdomains
    // Get VRF TXT record from another domain
}
