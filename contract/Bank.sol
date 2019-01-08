pragma solidity ^0.4.23;

contract Bank {
	// 此合約的擁有者
    address private owner;

	// 儲存所有會員的ether餘額
    mapping (address => uint256) private balance;

	// 儲存所有會員的coin餘額
    mapping (address => uint256) private coinBalance;

	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    event MintEvent(address indexed from, uint256 value, uint256 timestamp);
    event BuyCoinEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferCoinEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event TransferOwnerEvent(address indexed oldOwner, address indexed newOwner, uint256 timestamp);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }

	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        // emit DepositEvent
        emit DepositEvent(msg.sender, msg.value, now);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        // emit WithdrawEvent
        emit WithdrawEvent(msg.sender, etherValue, now);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        // emit TransferEvent
        emit TransferEvent(msg.sender, to, etherValue, now);
    }

	// mint coin
    function mint(uint256 coinValue) public isOwner {
        
        uint256 value = coinValue * 1 ether;

        // 增加 msg.sender 的 coinBalance
        coinBalance[msg.sender] += value;

        // emit MintEvent
        emit MintEvent(msg.sender, value, now);

    }

	// 使用 bank 中的 ether 向 owner 購買 coin
    function buy(uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;

        // require owner 的 coinBalance 不小於 value
        require(coinBalance[owner] >= value, "Owner's coin not enough");

        // require msg.sender 的 etherBalance 不小於 value
        require(balance[msg.sender] >= value, "Sender's ether balance not enough");

        // msg.sender 的 etherBalance 減少 value
        balance[msg.sender] -= value;
        
        // owner 的 etherBalance 增加 value
        balance[owner] += value;

        // msg.sender 的 coinBalance 增加 value
        coinBalance[msg.sender] += value;
        
        // owner 的 coinBalance 減少 value
        coinBalance[owner] -= value;
        

        // emit BuyCoinEvent
        emit BuyCoinEvent(msg.sender, value, now);

    }

	// 轉移 coin
    function transferCoin(address to, uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;

        // require msg.sender 的 coinBalance 不小於 value
        require(coinBalance[msg.sender] >= value, "Sender's coin not enough");
        
        // msg.sender 的 coinBalance 減少 value
        coinBalance[msg.sender] -= value;
        
        // to 的 coinBalance 增加 value
        coinBalance[to] += value;

        // emit TransferCoinEvent
        emit TransferCoinEvent(msg.sender, to, value, now);

    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    // 檢查coin餘額
    function getCoinBalance() public view returns (uint256) {
        return coinBalance[msg.sender];
    }

    // get owner
    function getOwner() public view returns (address)  {
        return owner;
    }

    // 轉移owner
    function transferOwner(address newOwner) public isOwner {
        
        address oldOwner = owner;

        // transfer ownership
        owner = newOwner;
        
        // emit TransferOwnerEvent
        emit TransferOwnerEvent(oldOwner, newOwner, now);
        
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }
}