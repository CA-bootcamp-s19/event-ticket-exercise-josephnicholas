pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "./EventAccounts.sol";

contract TestEventTicket {
    uint public initialBalance = 1 ether;

    EventTickets eventTickets;

    EventAccounts[4] accounts;

    function beforeEach() public {
        for(uint i = 0; i < accounts.length; i++) {
            accounts[i] = new EventAccounts();
            if(i == 0) {
                eventTickets = EventTickets(accounts[i].deployEventTicketsContract("Ethereum Bootcam Ed-End party", "consesnys.bootcamp.party", 1000));
            }
            accounts[i].setContractAddress(address(eventTickets));
        }
    }

    // buyItem
    function testBuyTickets() public {
        EventTickets(address(accounts[1])).buyTickets.value(2000 wei)(10);
        (string memory description, string memory url, uint totalTickets, uint sales, bool open) = eventTickets.readEvent();

        Assert.equal(description, 'Ethereum Bootcam Ed-End party', "Description should be the same as event details");
        Assert.equal(url, 'consesnys.bootcamp.party', "URL should be the same as the event details");
        Assert.equal(totalTickets, 990, 'Tickets available should be the same as the event details');
        Assert.equal(sales, 10, "Sale should be 1");
        Assert.equal(open, true, "Event sale should be open");
    }

    // buyItem with insufficient funds
    function testBuyTicketsInsufficientPayment() public {
        (bool result, ) = address(accounts[1]).call.value(200 wei)(abi.encodeWithSignature("buyTickets(uint256)", 10));
        Assert.isFalse(result, "should fail, insufficient payment");
    }

    // getRefund
    function testGetRefund() public {
        uint balance = address(accounts[1]).balance;
        EventTickets(address(accounts[1])).buyTickets.value(2000 wei)(10);
        EventTickets(address(accounts[1])).getRefund();
        (string memory description, string memory url, uint totalTickets, uint sales, bool open) = eventTickets.readEvent();

        Assert.equal(description, 'Ethereum Bootcam Ed-End party', "Description should be the same as event details");
        Assert.equal(url, 'consesnys.bootcamp.party', "URL should be the same as the event details");
        Assert.equal(totalTickets, 1000, 'Tickets available should be the same as the event details');
        Assert.equal(sales, 0, "Sale should be 1");
        Assert.equal(open, true, "Event sale should be open");
        Assert.isAbove(address(accounts[1]).balance, balance, "Balance should be different");
    }

    // getRefund no purchased tickets
    function testGetRefundNoTicketsPurchased() public {
        (bool result, ) = address(accounts[1]).call(abi.encodeWithSignature("getRefund()"));
        Assert.isFalse(result, "should fail, buyer has no tickets");
    }

    // endSale
    function testEndSale() public {
        uint balance = address(accounts[0]).balance;
        EventTickets(address(accounts[1])).buyTickets.value(2000 wei)(10);
        EventTickets(address(accounts[0])).endSale();
        (string memory description, string memory url, uint totalTickets, uint sales, bool open) = eventTickets.readEvent();

        Assert.equal(description, 'Ethereum Bootcam Ed-End party', "Description should be the same as event details");
        Assert.equal(url, 'consesnys.bootcamp.party', "URL should be the same as the event details");
        Assert.equal(totalTickets, 990, 'Tickets available should be the same as the event details');
        Assert.equal(sales, 10, "Sale should be 1");
        Assert.equal(open, false, "Event sale should be closed");
        Assert.isAbove(address(accounts[0]).balance, balance, "End balance should be greater after end sale");
    }

    // endSale not the Owner
    function testEndSaleNotOwner() public {
        EventTickets(address(accounts[1])).buyTickets.value(2000 wei)(10);
        (bool result, ) = address(accounts[1]).call(abi.encodeWithSignature("endSale()"));
        Assert.isFalse(result, "should fail, not the owner");
    }
}