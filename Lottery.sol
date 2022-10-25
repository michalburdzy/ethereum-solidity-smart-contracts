pragma solidity ^0.8.7;

contract Lottery {
  address public manager;
  address[] public participants;
  uint256 public minimumStake;

  constructor() {
    manager = msg.sender;
    minimumStake = 1;
  }

  function participate() public payable {
    require(msg.value >= minimumStake, 'Message value is less than a minimum lottery stake');

    participants.push(msg.sender);
  }

  function participantsCount() public view returns (uint) {
    return participants.length;
  }

  function getParticipants() public view returns (address[] memory){
    return participants;
  }

  function randomNumber(string calldata seed) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(seed, block.difficulty, participants, minimumStake)));
  }

  function pickWinner(string calldata seed) public payable restrictedManagerOnly returns (address) {
    require(participants.length > 0, 'No participants present');

    uint index = randomNumber(seed) % participants.length;
    address payable winner = payable(participants[index]);

    winner.transfer(address(this).balance);

    participants = new address[](0);

    return winner;
  }

  modifier restrictedManagerOnly() {
    require(msg.sender == manager);
    _;
  }
}