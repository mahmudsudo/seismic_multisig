// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Marketplace} from "../src/Market.sol";

contract DeployMarketplace {
    Marketplace public marketplace;

    constructor() {
        marketplace = new Marketplace();
        console.log("Marketplace contract deployed at:", address(marketplace));
    }
}
