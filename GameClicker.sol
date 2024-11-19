// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GameClicker {

    IERC20 public DZBToken;
    address owner;

    constructor(address token) {
        DZBToken = IERC20(token);
        owner = msg.sender;
    }

    uint public clikAllUsers = 1;
    uint public allUsers = 1;

    struct User {
        string name;
        uint balance;
        uint countClick;
        uint clickMultiplier;
        uint withdraw;
        uint lastClickTime;
        address referal;
        uint referalCount;
    }

    mapping(address => User) public users;

    address[] public userAddr;

    modifier CheckRegister() {
        require(bytes(users[msg.sender].name).length != 0, "User not already registered");
        _;
    }

    // checking the last click's value and the logic of increasing the balance from clicks and its multiplier
    modifier checkTimeClick() {
        User storage user = users[msg.sender];
        if (block.timestamp <= user.lastClickTime + 10) {
            user.countClick += 2;
            clikAllUsers += 2;
            user.balance += 2 * user.clickMultiplier * 2;
        } else {
            user.countClick += 1;
            clikAllUsers += 1;
            user.balance += 1 + user.clickMultiplier;
        }

        user.lastClickTime = block.timestamp;
        _;
    }

    modifier ChekRegisterRefiral() {
        require(bytes(users[msg.sender].name).length == 0, "User already register");
        _;
    }

    modifier OnlyOwner() {
        require(owner == msg.sender, "Not Owner");
        _;
    }


    function Register(string memory name) public {
        uint balance = users[msg.sender].balance + 0;
        users[msg.sender] = User(name, balance, 0, 1, 0, 0, address(0), 0);
        allUsers += 1;
        userAddr.push(msg.sender);
    }

    function RegisterReferal(string memory name, address referal) public ChekRegisterRefiral {
        uint balance = users[msg.sender].balance + 0;
        users[msg.sender] = User(name, balance, 0, 1, 0, 0, referal, 0);
        users[referal].balance += 500;
        users[referal].referalCount += 1;
        allUsers += 1;
        userAddr.push(msg.sender);
    }

    // sending in-game currency
    function Send(address recipient, uint amount) public CheckRegister {
        require(users[msg.sender].balance >= amount, "not enough balance");
        users[msg.sender].balance -= amount;
        users[recipient].balance += amount;
    }

    function Click() public CheckRegister checkTimeClick {}

    // Purchase of an improvement
    function payUpdate() public CheckRegister {
        uint cost = clikAllUsers / allUsers;
        users[msg.sender].balance -= cost;
        users[msg.sender].clickMultiplier++;
    }

    // sending tokens to players depending on their balance
    function payment(address recipient) public {
        require(users[recipient].balance >= 0, "negative balance");
        DZBToken.transferFrom(msg.sender, recipient, users[recipient].balance);
        users[recipient].balance = 0;
    }
}
