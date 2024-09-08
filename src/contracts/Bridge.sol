// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract UnifiedBridge {
    address public owner;
    address public sepoliaToken;  // Address of the token contract on Sepolia
    address public polygonToken;  // Address of the token contract on Polygon
    address public astarToken;    // Address of the token contract on Astar

    enum ChainId { Sepolia, PolygonZkEVM, Astar }
    
    event AssetBridged(
        ChainId indexed fromChain,
        ChainId indexed toChain,
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );

    constructor(address _sepoliaToken, address _polygonToken, address _astarToken) {
        owner = msg.sender;
        sepoliaToken = _sepoliaToken;
        polygonToken = _polygonToken;
        astarToken = _astarToken;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function bridgeAsset(
        ChainId fromChain,
        ChainId toChain,
        uint256 amount,
        address recipient,
        bool useToken,
        bytes memory data
    ) external onlyOwner {
        // Ensure amount is greater than 0
        require(amount > 0, "Amount must be greater than 0");

        address tokenAddress;
        
        // Determine which token to use based on the fromChain
        if (fromChain == ChainId.Sepolia) {
            tokenAddress = sepoliaToken;
        } else if (fromChain == ChainId.PolygonZkEVM) {
            tokenAddress = polygonToken;
        } else if (fromChain == ChainId.Astar) {
            tokenAddress = astarToken;
        } else {
            revert("Invalid chain");
        }
        
        IToken token = IToken(tokenAddress);
        require(token.transfer(recipient, amount), "Transfer failed");

        emit AssetBridged(fromChain, toChain, recipient, amount, block.timestamp);
    }

    function setTokenAddress(ChainId chain, address tokenAddress) external onlyOwner {
        if (chain == ChainId.Sepolia) {
            sepoliaToken = tokenAddress;
        } else if (chain == ChainId.PolygonZkEVM) {
            polygonToken = tokenAddress;
        } else if (chain == ChainId.Astar) {
            astarToken = tokenAddress;
        } else {
            revert("Invalid chain");
        }
    }
}
