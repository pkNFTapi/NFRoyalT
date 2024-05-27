# NFRoyalT
immutable creator commission

commission: a payment to someone who sells goods that is directly related to the amount sold, or a system that uses such payments

NFRoyalT.sol is a Solidity smart contract that implements an ERC721 Non-Fungible Token (NFT) with embedded royalty mechanisms. This contract allows the owner to mint NFTs and facilitates the transfer of these NFTs between users while ensuring that royalties are paid to the original creator.

Prerequisites

    Solidity version ^0.8.20
    OpenZeppelin Contracts:
        ERC721URIStorage
        Ownable

State Variables

    tokenCounter: A counter that tracks the number of tokens minted.
    creator: An immutable address that represents the original creator of the NFT. This address receives the royalty payments.
    fixedRoyalty: An immutable value representing a fixed royalty amount in wei.
    royaltyPercentage: A percentage value representing a royalty based on the sale price. This value is mutable and can be changed by the owner.

Events

    RoyaltyPaid: Emitted when royalties are paid to the creator.
        address indexed recipient: The address receiving the royalty payment.
        uint256 amount: The amount of royalty paid.
    NFTTransferred: Emitted when an NFT is transferred from one address to another.
        address indexed from: The address transferring the NFT.
        address indexed to: The address receiving the NFT.
        uint256 tokenId: The ID of the transferred NFT.
        uint256 salePrice: The sale price of the NFT.

Constructor
Parameters

    address payable _creator: The address that will receive the royalties. Must be non-zero.
    uint256 _fixedRoyalty: The fixed royalty amount in wei. Must be non-negative.
    uint256 _royaltyPercentage: The percentage of the sale price to be paid as royalty. Must be between 0 and 100.
    address initialOwner: The initial owner of the contract.

Functionality

    Sets the initial values for tokenCounter, creator, fixedRoyalty, and royaltyPercentage.
    Initializes the ERC721 and Ownable contracts with appropriate parameters.

Functions
createNFT

function createNFT(string memory _tokenURI) public onlyOwner returns (uint256)

Creates a new NFT with the specified token URI. Only callable by the contract owner.

Parameters:

    string memory _tokenURI: The URI of the token metadata.

Returns:

    uint256: The ID of the newly created token.

Functionality:

    Mints a new token to the caller's address.
    Sets the token URI for the newly created token.
    Increments the tokenCounter.

brokerTransfer

function brokerTransfer(address from, address to, uint256 tokenId, uint256 salePrice) public payable

Handles the transfer of an NFT from one address to another, ensuring that the appropriate royalty is paid to the creator. This function acts as a broker, managing the payment and transfer process.

Parameters:

    address from: The address transferring the NFT.
    address to: The address receiving the NFT.
    uint256 tokenId: The ID of the NFT being transferred.
    uint256 salePrice: The sale price of the NFT.

Functionality:

    Ensures the value sent with the transaction is at least equal to the sale price.
    Verifies that the from address is the owner of the token.
    Calculates the royalty amount based on the greater of the fixed royalty or percentage royalty.
    Transfers the calculated royalty to the creator.
    Transfers the remaining sale price to the seller.
    Transfers the NFT from the seller to the buyer.
    Emits RoyaltyPaid and NFTTransferred events.

setRoyaltyPercentage

function setRoyaltyPercentage(uint256 _royaltyPercentage) external onlyOwner

Allows the owner to set the percentage royalty for future transfers.

Parameters:

    uint256 _royaltyPercentage: The new percentage for royalties. Must be between 0 and 100.

Functionality:

    Updates the royaltyPercentage state variable.

tokenURI

function tokenURI(uint256 tokenId) public view override returns (string memory)

Overrides the ERC721 tokenURI function to return the token URI for a given token ID.

Parameters:

    uint256 tokenId: The ID of the token.

Returns:

    string memory: The URI of the token metadata.

Functionality:

    Ensures the token exists.
    Constructs and returns the full token URI based on the base URI and token ID.

Ether Reception Functions
receive

receive() external payable

Function to receive Ether. msg.data must be empty.
fallback

fallback() external payable

Function to receive Ether when msg.data is not empty.
