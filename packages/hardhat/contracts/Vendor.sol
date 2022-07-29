pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;

    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        require(msg.value > 0, "must send ether");
        uint256 tokenAmount = tokensPerEth * msg.value;
        yourToken.transfer(msg.sender, tokenAmount);

        emit BuyTokens(msg.sender, msg.value, tokenAmount);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        require(_amount >= 100, "too small amount");

        uint256 allowance = yourToken.allowance(msg.sender, address(this));
        if (allowance >= _amount) { // 判断批准代币数量是否满足当前请求数量, 满足, 则直接进行代币和eth交换.
            bool tranferSuccess = yourToken.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            require(tranferSuccess, "transfter YourToken failed");

            uint256 weiAmount = _amount / tokensPerEth;
            (bool success, ) = payable(msg.sender).call{value: weiAmount}("");
            require(success, "transfer Ether failed");

            emit SellTokens(msg.sender, weiAmount, _amount);
        } else { // 否则 请求用户进行重新授权代币数量.
            (bool approved, ) = address(yourToken).delegatecall(
                abi.encodeWithSelector(
                    ERC20.approve.selector,
                    address(this),
                    _amount
                )
            );
            require(approved, "failed to approve");
        }
    }
}
