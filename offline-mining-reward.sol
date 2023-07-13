// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Owner {

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
} 

/** 
 * @title Offline Mining Reward Distribution
 */
contract OfflineMining is Owner {
    uint256 private foundationTax;
    uint256 private coinbaseTax;
    uint256 private rewardPerHash;
    address payable foundation;

    event FoundationTax(uint256 indexed tax);
    event CoinbaseTax(uint256 indexed tax);
    event Reward(uint256 indexed tax);


    /** 
     * @dev Create a new contract to distribute the reward to foundation wallet, coinbase and miner wallet.
     * @param foundationWallet Foundation wallet address
     * @param fundTax Percent of foundation tax
     * @param coinTax Percent of coinbase tax
     * @param reward Reward in wei per hash
     */
    constructor(address payable foundationWallet, uint256 fundTax, uint256 coinTax, uint256 reward) {
        foundationTax = fundTax;
        coinbaseTax = coinTax;
        rewardPerHash = reward;
        foundation = foundationWallet;
    }

    /** 
     * @dev return current foundation wallet.
     */
    function getFoundationWallet() public view returns (address) {
        return foundation;
    }

    /** 
     * @dev return current taxes.
     */
    function getTaxes() public view returns (uint256, uint256) {
        return (foundationTax, coinbaseTax);
    }

    /** 
     * @dev set and emit foundation tax
     * @param tax Percent of foundation tax
     */
    function setFoundationTax(uint256 tax) public isOwner {
        emit FoundationTax(tax);
        foundationTax = tax;
    }

    /** 
     * @dev set and emit foundation tax
     * @param tax Percent of coinbase tax
     */
    function setCoinbaseTax(uint256 tax) public isOwner {
        emit CoinbaseTax(tax);
        coinbaseTax = tax;
    }

    /** 
     * @dev set and emit reward per difficulty 
     * @param reward Number of wei paid for each difficulty hash
     */
    function setReward(uint256 reward) public isOwner {
        emit Reward(reward);
        rewardPerHash = reward;
    }

    /** 
     * @dev set and emit reward per difficulty 
     * @param receiver Miner receiver address
     */
    function mine(address receiver) public payable {
        address payable to = payable(receiver);
        address payable coinbase = payable(block.coinbase);
        uint256 fReward = msg.value * foundationTax / 100;
        uint256 cReward = msg.value * coinbaseTax / 100;
        uint256 miner = msg.value - fReward - cReward;
        to.transfer(miner);
        foundation.transfer(fReward);
        coinbase.transfer(cReward);
    }
}