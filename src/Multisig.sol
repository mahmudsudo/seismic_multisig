pragma solidity ^0.8.0;

contract Multisig {
    address[] public signers;
    uint public threshold;
    uint public nonce;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint approvalCount;
    }

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public approvals;

    event TransactionSubmitted(
        uint indexed transactionId,
        address indexed sender
    );
    event TransactionApproved(
        uint indexed transactionId,
        address indexed approver
    );
    event TransactionExecuted(
        uint indexed transactionId,
        address indexed executor
    );

    constructor(address[] memory _signers, uint _threshold) {
        require(_threshold <= _signers.length, "Threshold too high");
        signers = _signers;
        threshold = _threshold;
    }

    modifier onlySigner() {
        bool isSigner = false;
        for (uint i = 0; i < signers.length; i++) {
            if (signers[i] == msg.sender) {
                isSigner = true;
                break;
            }
        }
        require(isSigner, "Not a signer");
        _;
    }

    function submitTransaction(
        saddress _to,
        suint _value,
        bytes memory _data
    ) public onlySigner {
        uint transactionId = nonce++;
        transactions[transactionId] = Transaction({
            to: address(_to),
            value: uint(_value),
            data: _data,
            executed: false,
            approvalCount: 0
        });
        emit TransactionSubmitted(transactionId, msg.sender);
    }

    function approveTransaction(suint _transactionId) public onlySigner {
        require(
            !transactions[uint(_transactionId)].executed,
            "Transaction already executed"
        );
        require(!approvals[uint(_transactionId)][msg.sender], "Already approved");

        approvals[uint(_transactionId)][msg.sender] = true;
        transactions[uint(_transactionId)].approvalCount++;

        emit TransactionApproved(uint(_transactionId), msg.sender);

        if (transactions[uint(_transactionId)].approvalCount >= threshold) {
            executeTransaction(_transactionId);
        }
    }

    function executeTransaction(suint _transactionId) public onlySigner {
        Transaction storage txn = transactions[uint(_transactionId)];
        require(!txn.executed, "Transaction already executed");
        require(txn.approvalCount >= threshold, "Not enough approvals");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");

        emit TransactionExecuted(uint(_transactionId), msg.sender);
    }
}
