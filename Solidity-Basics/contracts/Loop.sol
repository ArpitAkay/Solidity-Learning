// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract ExpenseTracker {
    struct Expense {
        address user;
        string description;
        uint amount;
    }

    Expense[] public expenses;

    constructor() {
        expenses.push(Expense(msg.sender, "Groceries", 50));
        expenses.push(Expense(msg.sender, "Transportation", 30));
        expenses.push(Expense(msg.sender, "Dining Out", 25));
    }

    function addExpense(string memory _description, uint _amount) public {
        expenses.push(Expense(msg.sender, _description, _amount));
    }

    function getTotalExpense(address _user) public view returns (uint){
        uint sum = 0;
        for(uint i=0; i<expenses.length; i++) {
            if(expenses[i].user == _user) {
                sum += expenses[i].amount;
            }
        }

        return sum;
    }
}