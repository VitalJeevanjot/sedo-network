pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/payment/escrow/Escrow.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract PaymentGateway is Ownable {
    Escrow escrow;
    address payable wallet;
    using SafeMath for uint256;

    constructor(address payable _wallet) public {
        escrow = new Escrow();
        wallet = _wallet;
    }

    function sendPayment() external payable {
        escrow.deposit.value(msg.value)(wallet);
    }

    function withdraw() external onlyOwner {
        escrow.withdraw(wallet);
    }

    function balance() external view onlyOwner returns (uint256) {
        return escrow.depositsOf(wallet);
    }
}
