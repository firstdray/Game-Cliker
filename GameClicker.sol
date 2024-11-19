// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GameClicker {

    IERC20 public DZBToken;
    address owner;

    constructor(address token) {
        DZBToken = IERC20(token);
        owner = msg.sender;
        DZBToken.approve(address(this), DZBToken.balanceOf(msg.sender));
    }

    uint public clikAllUsers = 1;
    uint public allUsers = 1;

    struct User {
        string name;
        uint balance;
        uint countClick;
        uint clickPay;
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

    modifier checkTimeClick() {
        User storage user = users[msg.sender];
        if (block.timestamp <= user.lastClickTime + 10) {
            user.countClick += 2;
            clikAllUsers += 2;
        } else {
            user.countClick += 1;
            clikAllUsers += 1;
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
        users[msg.sender] = User(name, balance, 0, 0, 0, 0, address(0), 0);
        allUsers += 1;
        userAddr.push(msg.sender);
    }

    function RegisterReferal(string memory name, address referal) public ChekRegisterRefiral {
        users[msg.sender] = User(name, 0, 0, 0, 0, 0, referal, 0);
        users[referal].balance += 500;
        users[referal].referalCount += 1;
        allUsers += 1;
        userAddr.push(msg.sender);
    }

    function Send(address recipient, uint amount) public CheckRegister {
        require(users[msg.sender].balance >= amount, "not enough balance");
        users[msg.sender].balance -= amount;
        users[recipient].balance += amount;
    }

    function Click() public CheckRegister checkTimeClick {}

    function payUpdate() public CheckRegister {
        uint cost = clikAllUsers / allUsers;
        users[msg.sender].balance -= cost;
    }

    function payment() public OnlyOwner {
        require(DZBToken.allowance(msg.sender, address(this)) >= DZBToken.balanceOf(msg.sender));
        for (uint i = 0; i < allUsers; i++) {
            address userAddress = userId(i);
            DZBToken.transferFrom(msg.sender, userAddress, users[userAddress].balance);
            users[userAddress].balance = 0;
        }
    }

    function userId(uint i) internal view  returns (address) {
        return userAddr[i];
    }

    function getBalance() public view returns (uint) {
        return DZBToken.balanceOf(msg.sender);
    }

}
