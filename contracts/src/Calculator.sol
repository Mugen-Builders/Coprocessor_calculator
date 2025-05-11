// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "coprocessor-adapter-2.3.0/src/CoprocessorAdapter.sol";

contract Calculator is CoprocessorAdapter {

    enum OperationType { Add, Subtract, Divide, Multiply }
    mapping (bytes32 => Record) public encodedRequestToResponse;
    mapping (address => bytes32[]) public userToRequestHistory;

    struct Operation {
        uint256 firstNumber;
        uint256 secondNumber;
        OperationType operation;
    }

    struct Record {
        uint id;
        bytes32 encodedRequest;
        bytes result;
    }

    event EncodedOperation(bytes encoded);
    event receivedResult(bytes result);

    constructor(address _taskIssuerAddress, bytes32 _machineHash)
        CoprocessorAdapter(_taskIssuerAddress, _machineHash)
    {}


    function handleNotice(bytes32 payloadHash, bytes memory notice) internal override {
        recordResult(payloadHash, notice);
    }

    function recordRequest(bytes32 request) internal {
        uint id = userToRequestHistory[msg.sender].length;
        Record memory record = Record(id, request, '0x00');
        userToRequestHistory[msg.sender].push(request);
        encodedRequestToResponse[request] = record;
    }

    function recordResult(bytes32 request, bytes memory response) internal {
        encodedRequestToResponse[request].result = response;
        emit receivedResult(response);
    }


    function add(uint256 a, uint256 b) external {
        Operation memory op = Operation(a, b, OperationType.Add);
        bytes memory encoded = abi.encode(op);
        emit EncodedOperation(encoded);
        recordRequest(keccak256(encoded));
        callCoprocessor(encoded);
    }

    function subtract(uint256 a, uint256 b) external{
        Operation memory op = Operation(a, b, OperationType.Subtract);
        bytes memory encoded = abi.encode(op);
        emit EncodedOperation(encoded);
        recordRequest(keccak256(encoded));
        callCoprocessor(encoded);
    }

    function divide(uint256 a, uint256 b) external {
        require(b != 0, "Division by zero");
        Operation memory op = Operation(a, b, OperationType.Divide);
        bytes memory encoded = abi.encode(op);
        emit EncodedOperation(encoded);
        recordRequest(keccak256(encoded));
        callCoprocessor(encoded);
    }

        function multiply(uint256 a, uint256 b) external {
        Operation memory op = Operation(a, b, OperationType.Multiply);
        bytes memory encoded = abi.encode(op);
        emit EncodedOperation(encoded);
        recordRequest(keccak256(encoded));
        callCoprocessor(encoded);
    }


}

