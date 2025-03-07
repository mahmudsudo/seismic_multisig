pragma solidity ^0.8.0;

contract MultiSigWallet {
    saddress[] public signers;
    suint public threshold;
    suint public nonce;

    struct Transaction {
        saddress to;
        suint value;
        bytes data;
        sbool executed;
        suint approvalCount;
    }

    mapping(suint => Transaction) public transactions;
    mapping(suint => mapping(saddress => sbool)) public approvals;

    event TransactionSubmitted(
        suint indexed transactionId,
        saddress indexed sender
    );
    event TransactionApproved(
        suint indexed transactionId,
        saddress indexed approver
    );
    event TransactionExecuted(
        suint indexed transactionId,
        saddress indexed executor
    );

    constructor(saddress[] memory _signers, suint _threshold) {
        require(_threshold <= _signers.length, "Threshold too high");
        signers = _signers;
        threshold = _threshold;
    }

    modifier onlySigner() {
        sbool isSigner = false;
        for (suint i = 0; i < signers.length; i++) {
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
        suint transactionId = nonce++;
        transactions[transactionId] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            approvalCount: 0
        });
        emit TransactionSubmitted(transactionId, msg.sender);
    }

    function approveTransaction(suint _transactionId) public onlySigner {
        require(
            !transactions[_transactionId].executed,
            "Transaction already executed"
        );
        require(!approvals[_transactionId][msg.sender], "Already approved");

        approvals[_transactionId][msg.sender] = true;
        transactions[_transactionId].approvalCount++;

        emit TransactionApproved(_transactionId, msg.sender);

        if (transactions[_transactionId].approvalCount >= threshold) {
            executeTransaction(_transactionId);
        }
    }

    function executeTransaction(suint _transactionId) public onlySigner {
        Transaction storage txn = transactions[_transactionId];
        require(!txn.executed, "Transaction already executed");
        require(txn.approvalCount >= threshold, "Not enough approvals");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");

        emit TransactionExecuted(_transactionId, msg.sender);
    }
}
