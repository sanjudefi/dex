// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}

contract DecentralizedExchange {
    address public admin;
    Token public token;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, uint256 amount, uint256 revenue);

    constructor(address _tokenAddress) {
        admin = msg.sender;
        token = Token(_tokenAddress);
    }

    function buyTokens(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        uint256 cost = amount * 1 ether; // 1 ether per token
        
        require(msg.value == cost, "Ether value does not match the cost");
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens available in the DEX");

        token.transfer(msg.sender, amount);
        emit TokensPurchased(msg.sender, amount, cost);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient tokens in your account");

        uint256 revenue = amount * 1 ether; // 1 ether per token
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(revenue);
        emit TokensSold(msg.sender, amount, revenue);
    }

    function withdrawEther() public {
        require(msg.sender == admin, "Only the admin can withdraw");
        payable(admin).transfer(address(this).balance);
    }
}