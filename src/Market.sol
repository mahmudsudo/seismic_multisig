// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {

    // Declare an array to hold marketplace addresses
    address[] public participants;

    // Mapping to quickly check if an address exists in the participants
    mapping(address => bool) public isParticipant;

    // Event to signal when an address is added or removed
    event ParticipantAdded(address indexed participant);
    event ParticipantRemoved(address indexed participant);

    // Function to add an address to the participants array
    function addParticipant(address participant) public {
        require(!isParticipant[participant], "Address already a participant");

        // Add to participants array and map it to true
        participants.push(participant);
        isParticipant[participant] = true;

        emit ParticipantAdded(participant);
    }

    // Function to remove an address from the participants array
    function removeParticipant(address participant) public {
        require(isParticipant[participant], "Address is not a participant");

        // Find the index of the participant to remove
        uint index = 0;
        for (uint i = 0; i < participants.length; i++) {
            if (participants[i] == participant) {
                index = i;
                break;
            }
        }

        // Remove the participant from the array
        participants[index] = participants[participants.length - 1];
        participants.pop();
        isParticipant[participant] = false;

        emit ParticipantRemoved(participant);
    }

    // Get total number of participants
    function getTotalParticipants() public view returns (uint) {
        return participants.length;
    }
}
