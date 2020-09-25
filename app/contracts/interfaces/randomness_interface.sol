pragma solidity 0.6.6;

interface randomness_interface {
    function randomNumber(uint256) external view returns (uint256);

    function getRandom(string calldata) external;
    
    function getDomainNameForTXT(uint256 txt) external view returns(string memory);
}
