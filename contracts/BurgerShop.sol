// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0 < 0.9.0;


contract BurgerShop {
    uint256 public cost = 0.2 ether;
    uint256 public deluxCost = 0.4 ether;
    uint256 public startDate = block.timestamp + 1 minutes; 
    uint256 public burgerCount = 100;
    address public owner;
    mapping (address => uint256) public userRefunds;
    bool public paused = false; 

    event BoughtBurger(address indexed _from, uint256 cost);

    enum Stages{
        readyToOrder,
        makeBurger,
        deliverBurger
    }

    Stages public burgerShopStage = Stages.readyToOrder;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner, "not authorized");
        _;
    }

    modifier shopOpened(){
        require(block.timestamp > startDate, "not open");
        _;
    }

    modifier notPased(){
        require(paused == false, "cannot carry out operation");
        _;
    }

    modifier correctAmount(){
         require(msg.value == cost || msg.value == deluxCost, "not the correct amount");
         _;
    }

    modifier isAtStage(Stages _stage){
        require(burgerShopStage == _stage, "not the correct stage");
        _;
    }

    function buyBurger(uint _price) public payable correctAmount isAtStage(Stages.readyToOrder) shopOpened notPased {
        require(msg.value == cost, "wrong amount");
        updateStage(Stages.makeBurger);
        burgerCount --;
        emit BoughtBurger(msg.sender, _price);
        payable(msg.sender).transfer(_price);
    }

    function refund(address _to, uint256 _cost) public payable  correctAmount onlyOwner {
        require(_cost == cost || _cost == deluxCost, "wrong amount");
        require(address(this).balance >= _cost, "not enough funds");
        userRefunds[_to] = _cost;
    }

    function claimRefund() public payable {
        uint256 value = userRefunds[msg.sender];
        userRefunds[msg.sender] = 0;
        (bool success,)= payable(msg.sender).call{value: value}("");
        require(success);
    }
    
    function getFunds() public view returns (uint256){
        return address(this).balance;
    }

    function madeBurger() public isAtStage(Stages.makeBurger) shopOpened{
        updateStage(Stages.deliverBurger);
    }

    function pickUpBurger() public isAtStage(Stages.deliverBurger) shopOpened{
        updateStage(Stages.readyToOrder);
    }

    function updateStage(Stages _stage) public shopOpened{
        burgerShopStage = _stage;
    }

    function getRandomNum(uint256 _seed) public  view returns (uint256){
        uint256 ranNum = uint256(keccak256(abi.encodePacked(block.timestamp, _seed))) % 10 + 1;
        return ranNum;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}