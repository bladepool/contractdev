// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./PrivateAllocationContract.sol"; 

contract MyToken is ERC20 {
     
    address public owner;
    PrivateAllocationContract public privateAllocationInstance;
    bool public isClaimingActive = false;
    mapping(address => bool) public hasClaimed; 
    mapping(address => bool) public isWhitelisted; 
    address[] public whitelistedAddresses; 
    address public recipient;

//Logging and Troubleshooting section to record data on blockchain
event _claimedCompleted (address account);
event _whitelistAdded();
event _whitelistRemoved();
event TokensClaimed(address indexed claimer, uint256 amount);
//Definition
    string constant private _name = "TokenName";
    string constant private _symbol = "TokenSymbol";
    
    constructor( ) ERC20(_name, _symbol) {
       owner = msg.sender;
       _mint(owner, 50000000 * 10 ** decimals());
        privateAllocationInstance = PrivateAllocationContract(0x40db0304b47f470c35A18563623B65ea04E45DAA);
    }

    function toggleClaiming() external {
        require(msg.sender == owner, "Only the owner can toggle claiming");
        isClaimingActive = !isClaimingActive;
        emit _claimedCompleted(msg.sender);
    }

    function getWhitelistedAddresses() public view returns (address[] memory) {
    return whitelistedAddresses;
    }

    function addToWhitelist(address whitelistedAddress) external {
        require(msg.sender == owner, "Only the owner can add addresses to the whitelist");
        require(!isWhitelisted[whitelistedAddress], "Address is already whitelisted");

        isWhitelisted[whitelistedAddress] = true;
        whitelistedAddresses.push(whitelistedAddress);
        emit _whitelistAdded();
    }

    function addMultipleToWhitelist(address[] calldata addresses) external {
        require(msg.sender == owner, "Only the owner can add addresses to the whitelist");
        
        for (uint i = 0; i < addresses.length; i++) {
            if (!isWhitelisted[addresses[i]]) {
                isWhitelisted[addresses[i]] = true;
                whitelistedAddresses.push(addresses[i]);
            }
        }
        emit _whitelistAdded();
    }

    function removeFromWhitelist(address whitelistedAddress) external {
        require(msg.sender == owner, "Only the owner can remove addresses from the whitelist");
        require(isWhitelisted[whitelistedAddress], "Address is not whitelisted");

        isWhitelisted[whitelistedAddress] = false;
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == whitelistedAddress) {
                whitelistedAddresses[i] = whitelistedAddresses[whitelistedAddresses.length - 1];
                whitelistedAddresses.pop();
                break;
            }
        }
        emit _whitelistRemoved();
    }

    function claim() external {
    require(isClaimingActive, "Claiming is not active");
    require(!hasClaimed[msg.sender], "Tokens already claimed for this address");

    uint claimAmount = privateAllocationInstance.allocationAmount(msg.sender);
    require(claimAmount > 0, "No tokens to claim for this address");

    if (isWhitelisted[msg.sender]) {
        claimAmount = claimAmount * 39900; 
    } else {
        claimAmount = claimAmount * 27000; 
    }
    hasClaimed[msg.sender] = true; 
    _transfer(owner, msg.sender, claimAmount);
    emit TokensClaimed(msg.sender, claimAmount);
}

}