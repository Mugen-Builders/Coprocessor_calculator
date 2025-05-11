// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "coprocessor-adapter-2.3.0/src/CoprocessorAdapter.sol";

contract Calculator is CoprocessorAdapter {

    enum OperationType { Add, Subtract, Divide, Multiply }

    uint256 totalRequest;

    mapping (bytes32 => Record) public encodedRequestToResponse;
    mapping (address => History[]) public userToRequestHistory;

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

    struct History {
        uint256 requestId;
        bytes32 request;
        uint256 requestTime;
    }

    event EncodedOperation(bytes encoded);
    event receivedResult(bytes result);
    event ComputationResultAlreadyExists(bytes32 request, bytes result);

    constructor(address _taskIssuerAddress, bytes32 _machineHash)
        CoprocessorAdapter(_taskIssuerAddress, _machineHash)
    {}

    function getUserRequests(address user) public view returns (History[] memory) {
        return userToRequestHistory[user];
    }

    function getRequestResponse( bytes32 request) public view returns (Record memory) {
        return encodedRequestToResponse[request];
    }


    function handleNotice(bytes32 payloadHash, bytes memory notice) internal override {
        recordResult(payloadHash, notice);
    }

    function recordRequest(bytes32 request) internal returns (bool) {
        totalRequest ++;
        uint id = userToRequestHistory[msg.sender].length;

        History memory newHistory = History(id, request, block.timestamp);
        userToRequestHistory[msg.sender].push(newHistory);

        if (encodedRequestToResponse[request].id == 0) {
            Record memory record = Record(totalRequest, request, '0x00');
            encodedRequestToResponse[request] = record;
            return true;
        } else {
            bytes memory result =  encodedRequestToResponse[request].result;
            Record memory record = Record(totalRequest, request, result);
            encodedRequestToResponse[request] = record;
            emit ComputationResultAlreadyExists(request, result);
            return false;
        }
        
    }

    function recordResult(bytes32 request, bytes memory response) internal {
        encodedRequestToResponse[request].result = response;
        emit receivedResult(response);
    }


    function add(uint256 a, uint256 b) external {
        Operation memory op = Operation(a, b, OperationType.Add);
        bytes memory encoded = abi.encode(op);
        if (recordRequest(keccak256(encoded))) {
            callCoprocessor(encoded);
        }
        emit EncodedOperation(encoded);
    }

    function subtract(uint256 a, uint256 b) external{
        Operation memory op = Operation(a, b, OperationType.Subtract);
        bytes memory encoded = abi.encode(op);
        if (recordRequest(keccak256(encoded))) {
            callCoprocessor(encoded);
        }
        emit EncodedOperation(encoded);
    }

    function divide(uint256 a, uint256 b) external {
        require(b != 0, "Division by zero");
        Operation memory op = Operation(a, b, OperationType.Divide);
        bytes memory encoded = abi.encode(op);
        if (recordRequest(keccak256(encoded))) {
            callCoprocessor(encoded);
        }
        emit EncodedOperation(encoded);
    }

    function multiply(uint256 a, uint256 b) external {
        Operation memory op = Operation(a, b, OperationType.Multiply);
        bytes memory encoded = abi.encode(op);
        if (recordRequest(keccak256(encoded))) {
            callCoprocessor(encoded);
        }
        emit EncodedOperation(encoded);
    }
}

