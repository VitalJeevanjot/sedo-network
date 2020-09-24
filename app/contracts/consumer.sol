// Deployed at 0xE9B8a01Aecc1F32E1914678228db6a5aa6bD833d

pragma solidity 0.6.6;

import "./chainlink_contracts/chainlink/ChainlinkClient.sol";
import "./chainlink_contracts/chainlink/vendor/Ownable.sol";

contract ATestnetConsumer is ChainlinkClient, Ownable {
    uint256 private constant ORACLE_PAYMENT = (1 * LINK) / 10;

    uint256 public currentPrice;
    int256 public changeDay;
    bytes32 public lastMarket;

    event RequestEthereumPriceFulfilled(
        bytes32 indexed requestId,
        uint256 indexed price
    );

    event RequestEthereumChangeFulfilled(
        bytes32 indexed requestId,
        int256 indexed change
    );

    event RequestEthereumLastMarket(
        bytes32 indexed requestId,
        bytes32 indexed market
    );

    constructor() public Ownable() {
        setPublicChainlinkToken();
    }

    function requestEthereumPrice(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillEthereumPrice.selector
        );
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );
        req.add("path", "USD");
        req.addInt("times", 100);
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestEthereumChange(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillEthereumChange.selector
        );
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );
        req.add("path", "RAW.ETH.USD.CHANGEPCTDAY");
        req.addInt("times", 1000000000);
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestEthereumLastMarket(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillEthereumLastMarket.selector
        );
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );
        string[] memory path = new string[](4);
        path[0] = "RAW";
        path[1] = "ETH";
        path[2] = "USD";
        path[3] = "LASTMARKET";
        req.addStringArray("path", path);
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillEthereumPrice(bytes32 _requestId, uint256 _price)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestEthereumPriceFulfilled(_requestId, _price);
        currentPrice = _price;
    }

    function fulfillEthereumChange(bytes32 _requestId, int256 _change)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestEthereumChangeFulfilled(_requestId, _change);
        changeDay = _change;
    }

    function fulfillEthereumLastMarket(bytes32 _requestId, bytes32 _market)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestEthereumLastMarket(_requestId, _market);
        lastMarket = _market;
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
