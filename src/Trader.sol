// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Market.sol";

contract Ecommerce {

    // Reference to the Marketplace contract
    Marketplace public marketplace;

    // Discount rate 
    uint public discountRate = 10;

    // Event to signal when discount is applied
    event DiscountApplied(address indexed buyer, uint discountAmount, uint finalPrice);

    // Constructor to set the marketplace contract address
    constructor(address marketplaceAddress) {
        marketplace = Marketplace(marketplaceAddress);
    }

    // Function to apply discount if buyer is in the marketplace
    function applyDiscount(saddress buyer, suint price) public returns (uint) {
        // Check if the buyer is in the marketplace
        if (marketplace.isParticipant(address(buyer))) {
            uint discountAmount = (uint(price) * discountRate) / 100;
            uint finalPrice = uint(price) - discountAmount;

            emit DiscountApplied(address(buyer), discountAmount, finalPrice);

            return finalPrice;
        } else {
            return uint(price);  // No discount if not a participant
        }
    }

    // Function to set the discount rate
    function setDiscountRate(suint newDiscountRate) public {
        discountRate = uint(newDiscountRate);
    }

    // Function to add a new participant to the Marketplace
    function addMarketplaceParticipant(saddress participant) public {
        marketplace.addParticipant(address(participant));
    }

    // Function to remove a participant from the Marketplace
    function removeMarketplaceParticipant(address participant) public {
        marketplace.removeParticipant(participant);
    }
}
// ecommerce :  0x53553741Fd94b66ab7a4A6D1A240aD0DF2Cc1167
// sforge create src/Trader.sol:Ecommerce --rpc-url https://node-2.seismicdev.net/rpc  --private-key 503c06a561fb47276659112850486f3d5edca3aba2e82e12549dcd37f10b870d --broadcast --constructor-args  0x9EA16DfAa9Cfcba13576de7144E20Cf04B340e85