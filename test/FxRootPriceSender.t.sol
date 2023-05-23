// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/FxRootPriceSender.sol";
import "../src/FxRootPriceReceiver.sol";

contract FxRootPriceSenderTest is Test {
    FxPriceReader public priceReader;
    FxRootPriceReceiver public receiver;

    function setUp() public {
        priceReader = new FxPriceReader(0x9571B72000234f886f202034225fd4eee3E829fF,0x99530b06);
        receiver = new FxRootPriceReceiver(address(priceReader));
        
    }

    function testCanSendValue() public {
        priceReader.setNewTarget(address(receiver));
        priceReader.sendValue();
    }

    
}
