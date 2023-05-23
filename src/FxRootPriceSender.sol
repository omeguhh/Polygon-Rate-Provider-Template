// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/access/Ownable.sol";

///@title Rate Provider Sender


interface IFxStateSender {
    function sendMessageToChild(address _receiver, bytes calldata _data) external;
}


contract FxPriceReader is Ownable{
    address private tokenAddress;
    address private fxRoot = 0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2; //mainnet 

    uint256 price;
    address target;
    bytes4 fnSelector;

    event ValueSent(address target, uint256 price);
    event NewTargetSet(address _oldTarget, address _newTarget);
   

    constructor(address _tokenAddress, bytes4 _fnSelector) {
        tokenAddress = _tokenAddress;
        price = 0;
        fnSelector = _fnSelector;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        PUBLIC Methods                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    
    ///@notice Sending value to be synced on PoS or zkEVM
    function sendValue() public {
        bytes memory data = abi.encodeWithSelector(fnSelector);
        (bool success, bytes memory res) = address(tokenAddress).call(data);
        if(success) {
            price = abi.decode(res, (uint256));
            IFxStateSender(fxRoot).sendMessageToChild(target, res);
            emit ValueSent(target, price);
        }
    }

    function currentValue() public returns (uint256) {
        bytes memory data = abi.encodeWithSelector(fnSelector);
        (bool success, bytes memory res) = address(tokenAddress).call(data);
        if(success) {
            price = abi.decode(res, (uint256));   
        }
        return price;
    }

    function currentTarget() public view returns(address){
        return target;
    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        PRIVATE Methods                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    ///@notice Update receiver target
    ///@param _target is the new target receiver address
    function setNewTarget(address _target) public onlyOwner{
        emit NewTargetSet(target, _target);
        target =_target;
    }
}
