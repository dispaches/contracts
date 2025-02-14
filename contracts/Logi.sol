// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract LogisticsPoD {
    enum Role { None, Customer, Rider }
    struct User {
        Role role;
        bool registered;
    }
    
    struct Delivery {
        address rider;
        address customer;
        string ipfsHash; // Stores PoD data (photo, signature, geolocation)
        uint256 timestamp;
        bool verified;
    }
    
    mapping(address => User) public users;
    mapping(uint256 => Delivery) public deliveries;
    mapping(address => uint256) public balances;
    uint256 public deliveryCount;
    address public owner;
    
    event UserRegistered(address indexed user, Role role);
    event DeliverySubmitted(uint256 indexed deliveryId, address rider, string ipfsHash);
    event DeliveryVerified(uint256 indexed deliveryId, address rider, uint256 payment);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function registerUser(Role _role) external {
        require(users[msg.sender].role == Role.None, "Already registered");
        users[msg.sender] = User(_role, true);
        emit UserRegistered(msg.sender, _role);
    }
    
    function submitDelivery(string memory _ipfsHash) external onlyRegistered {
        require(users[msg.sender].role == Role.Rider, "Only riders can submit delivery");
        deliveries[deliveryCount] = Delivery(msg.sender, address(0), _ipfsHash, block.timestamp, false);
        emit DeliverySubmitted(deliveryCount, msg.sender, _ipfsHash);
        deliveryCount++;
    }
    
    function verifyDelivery(uint256 _deliveryId, address _customer) external onlyOwner {
        Delivery storage delivery = deliveries[_deliveryId];
        require(!delivery.verified, "Already verified");
        
        delivery.verified = true;
        delivery.customer = _customer;
        
        uint256 paymentAmount = 0.01 ether; // Set payment amount
        balances[delivery.rider] += paymentAmount;
        
        emit DeliveryVerified(_deliveryId, delivery.rider, paymentAmount);
    }
    
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    
    function getAllDeliveries() external view returns (Delivery[] memory) {
        Delivery[] memory allDeliveries = new Delivery[](deliveryCount);
        for (uint256 i = 0; i < deliveryCount; i++) {
            allDeliveries[i] = deliveries[i];
        }
        return allDeliveries; 
    }
    
    receive() external payable {} // Accept ETH for payments
}
