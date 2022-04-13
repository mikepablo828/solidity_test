// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.10 and less than 0.9.0
pragma solidity ^0.8.10;

import "hardhat/console.sol";

contract Split {
    struct Proportion {
        address account;
        uint256 share;
    }

    mapping (address => uint256) public balance;
    uint256 private totalShare;
    address public owner;
    uint256 private lastRun;
    Proportion[] private addressList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalShare = 0;
    }

    function addToList(address _to, uint _share) external onlyOwner {
        require(_share > 0, "Invalid share");
        require(_to != address(0), "Invalid address");

        addressList.push(Proportion(_to, _share));
        totalShare += _share;
    }

    function deposit() external payable {
        require(totalShare > 0, "Not splitter yet");

        uint256 dividend = msg.value / totalShare;
        
        for (uint i = 0; i < addressList.length; i++) {
            Proportion memory addressItem = addressList[i];
            balance[addressItem.account] += addressItem.share * dividend;
        }

        lastRun = block.timestamp;
        console.log("Last Run: ", lastRun);
    }

    function withdraw() external {
        require(block.timestamp - lastRun > 30 days, 'Need to wait 1 month');        
        require(balance[msg.sender] > 0, 'Invailid balance');

        uint256 _balance = balance[msg.sender];
        balance[msg.sender] = 0;
        payable(msg.sender).transfer(_balance);
    }

    function testWithdraw(address account) external {
        console.log("Current Time: ", block.timestamp);
        require(block.timestamp - lastRun > 2, 'Need to wait 2 second');
        uint256 _balance = balance[account];
        require(_balance > 0, 'Invailid balance');
        balance[account] = 0;
        payable(account).transfer(_balance);
    }
}