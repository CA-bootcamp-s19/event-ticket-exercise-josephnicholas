pragma solidity ^0.5.0;

import "./Proxy.sol";
import "../contracts/EventTickets.sol";

contract EventAccounts is Proxy {
    function deployEventTicketsContract(string calldata description, string calldata URL, uint ticketsAvailable) external returns(address) {
        return address(new EventTickets(description, URL, ticketsAvailable));
    }
}