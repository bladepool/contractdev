// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;



contract PrivateAllocationContract  {
    struct Participant {
        address participantAddress;
        uint allocationAmount;
    }

    address constant public recipient = 0xEab8573343887E16efCfc6bD9C31b4f28e80ba84;
    address public owner; 
    address[] participants;
    mapping (address => uint) public allocationAmount; // st  ore participant's contribution amount
    mapping(address => bool) inserted;
    bool public isActive = true;
    event DonationReceived(address indexed donor, uint256 amount);
    event _pauseCompleted();
    event _whitedrawalCompleted(address account);

    constructor() {
        owner = msg.sender;
    }

    function contribute() public payable  {
        require(isActive , "ICO paused");
        uint _amount = msg.value;
        require((_amount >= 0.1 * 10 **18) && (_amount <= 10 * 10 **18), "Over the allowed range");

        if (inserted[msg.sender]) {
            allocationAmount[msg.sender] += _amount;
        } else {
            inserted[msg.sender] = true;
            allocationAmount[msg.sender] = _amount;
            participants.push(msg.sender);
        }
        emit DonationReceived(msg.sender, _amount);
    }

    

    function getParticipants() public view returns (Participant[] memory) {
        Participant[] memory result = new Participant[](participants.length);
        for (uint i = 0; i < participants.length; i++) {
            result[i] = Participant(participants[i], allocationAmount[participants[i]]);
        }
        return result;
    }

    function getETHBalance() public view returns(uint){
        return address(this).balance;
    }

    function pause() public {
        require(msg.sender == owner, "Only the owner can pause the ico");
        isActive = !isActive;
        emit _pauseCompleted(); 
    }

    function withdraw(uint _amount) public {
        require(msg.sender == owner, "Only the owner can withdraw tokens");
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = recipient.call{value: _amount}("");
        require(success, "Transfer failed");
        emit _whitedrawalCompleted(msg.sender);
    }
}