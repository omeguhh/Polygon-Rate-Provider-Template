// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/access/Ownable.sol";

///@title Rate Provider Receiver
///@notice Updates price value to sync with Mainnet

interface IFxMessageProcessor {
    function processMessageFromRoot(
        uint256 stateId,
        address rootMessageSender,
        bytes calldata data
    ) external;
}

contract FxRootPriceReceiver is Ownable{


    address fxChild = 0x8397259c983751DAf40400790063935a11afa28a; //Polygon
    address fxRootSender; 

    uint256 xChainPrice;

    event MessageProcessed(address _rootMessageSender, bytes _data);
    event SenderChanged(address _oldSender, address _newSender);

    constructor(address _fxRootSender) {
        fxRootSender = _fxRootSender;
    }

    modifier onlyFxChild() {
    require(msg.sender == fxChild, 'UNAUTHORIZED_CHILD_ORIGIN');
        _;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        PUBLIC Methods                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    ///@notice Gets current value
    function getRate() public view returns (uint256){
        return xChainPrice;
    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        PRIVATE Methods                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


    ///@notice updates the value of xChainPrice 
    ///@param stateId counter to record tx
    ///@param rootMessageSender must be equal to the value of fxRootSender
    ///@param data holds the new value of xChainPrice
    function processMessageFromRoot(uint256 stateId, address rootMessageSender, bytes calldata data) external onlyFxChild {
        require(rootMessageSender == fxRootSender, 'UNAUTHORIZED_ROOT_ORIGIN');
        xChainPrice = abi.decode(data, (uint256));
        emit MessageProcessed(rootMessageSender, data);
    }

    ///@notice Update FxPriceReader address
    ///@param _newRootSender the new address for the FxPriceSender
    function changeSender(address _newRootSender) public onlyOwner {
        emit SenderChanged(fxRootSender, _newRootSender);
        fxRootSender = _newRootSender;
    }


    


}