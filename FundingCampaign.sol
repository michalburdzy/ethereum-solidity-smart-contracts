// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Campaign {

    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }


    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public contributors;
    uint  public contributorsCount;

  constructor(uint minContrib) {
    manager = msg.sender;  
    minimumContribution = minContrib;
  }

  function contribute() public payable {
    require(msg.value >= minimumContribution, 'Message value is less than a minimum contribution amount');

    contributors[msg.sender] = true;
    contributorsCount++;
  }

  function createRequest(string calldata description, uint value, address recipient) public restrictedManagerOnly {
      Request storage newRequest = requests.push();
      
      newRequest.description = description;
      newRequest.value = value;
      newRequest.recipient = payable(recipient);
      newRequest.complete = false;
      newRequest.approvalCount = 0;
  }

  function approveRequest(uint requestIndex) public {
      Request storage request = requests[requestIndex];
      
      require(contributors[msg.sender], 'Only contributors can approve requests');
      require(!request.approvals[msg.sender], 'You can approve request only once');

      request.approvalCount++;
      request.approvals[msg.sender] = true;
  }

  function finalizeRequest(uint requestIndex) public restrictedManagerOnly {
    Request storage request = requests[requestIndex];
    require(!request.complete, 'Request is already complete');
    require(request.approvalCount > (contributorsCount / 2), 'Minimum of 50% approvals from contributors treshold not meet');
    require(request.value <= address(this).balance, 'Request value is bigger than contract total balance');

    request.recipient.transfer(request.value);

    request.complete = true;
  }

  modifier restrictedManagerOnly() {
    require(msg.sender == manager, 'Only manager can perform this action');
    _;
  }
}