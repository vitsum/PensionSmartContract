pragma solidity ^0.4.15;

contract Pension {
    
    address owner;
    
    struct Client {
        uint256 balance;
        uint delayDays;
        uint creationDate;
        uint256 paymentPerMonth;
        uint256 paid;
    }
    
    mapping (address => Client) clients;
    
    function Pension(){
        owner = msg.sender;
    }
    
    function Deposit(uint delayDays, uint256 paymentPerMonth) payable {
        require(paymentPerMonth > 0);
        
        Client storage client = clients[msg.sender];
        client.balance += msg.value;
        if(client.creationDate == 0) {
            client.creationDate = now;
            client.paymentPerMonth = paymentPerMonth;
            client.delayDays = delayDays;
            client.paid = 0;
        }
    }
    
    function PayoutFull(address clientAddress) {
        require(msg.sender == owner);
        
        Client storage client = clients[clientAddress];
        require(client.balance > 0);
        
        uint256 amount = client.balance;
        client.balance = 0;
        client.paid += amount;
        clientAddress.transfer(amount);
        
    }
    
    function ReceivePayment() {
        Client storage client = clients[msg.sender];
        require(client.balance > 0);
        require(now - client.creationDate > client.delayDays * 1 days);
        
        uint256 shouldBePaidToDate = client.paymentPerMonth * (now - client.creationDate - client.delayDays * 1 days) / 30 days;

        uint256 amount = shouldBePaidToDate - client.paid;
        
        require(amount > 0);
        if(amount > client.balance) amount = client.balance;
        client.balance -= amount;
        client.paid += amount;
        
        msg.sender.transfer(amount);
        
    }
    
    //debug functions only for development, should be removed before publishing
    
    function SetClient(address addr, uint256 balance, uint delayDays, uint creationDate, uint256 paymentPerMonth, uint256 paid){
        Client storage client = clients[addr];
        client.balance = balance;
        client.delayDays = delayDays;
        client.creationDate = creationDate;
        client.paymentPerMonth = paymentPerMonth;
        client.paid = paid;
    }
}
