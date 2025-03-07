// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Logi {
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
    event FundsWithdrawn(address indexed user, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }
    
    modifier onlyRole(Role _role) {
        require(users[msg.sender].role == _role, "Unauthorized role");
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

    function getUser(address userAddress) external view returns (Role) {
        return users[userAddress].role;
    }

    function registerOrder() external onlyRole(Role.Customer) {
        deliveries[deliveryCount] = Delivery({
            rider: address(0),
            customer: msg.sender,
            ipfsHash: "",
            timestamp: block.timestamp,
            verified: false
        });
        deliveryCount++;
    }
    
    function submitDelivery(uint256 _deliveryId, string memory _ipfsHash) external onlyRole(Role.Rider) {
        require(_deliveryId < deliveryCount, "Invalid delivery ID");
        Delivery storage delivery = deliveries[_deliveryId]; 
        require(delivery.customer != address(0), "Order not assigned");
        require(delivery.rider == address(0), "Delivery already submitted");
        
        delivery.rider = msg.sender;
        delivery.ipfsHash = _ipfsHash;
        delivery.timestamp = block.timestamp;
        delivery.verified = false;
        
        emit DeliverySubmitted(_deliveryId, msg.sender, _ipfsHash);
    }
    
    function verifyDelivery(uint256 _deliveryId) external onlyOwner {
        require(_deliveryId < deliveryCount, "Invalid delivery ID");
        Delivery storage delivery = deliveries[_deliveryId]; 
        require(!delivery.verified, "Already verified");
        require(delivery.rider != address(0), "Delivery not submitted");
        
        delivery.verified = true;
        
        uint256 paymentAmount = 0.01 ether; // Payment amount
        balances[delivery.rider] += paymentAmount;
        
        emit DeliveryVerified(_deliveryId, delivery.rider, paymentAmount);
    }
    
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        balances[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
        emit FundsWithdrawn(msg.sender, amount);
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
