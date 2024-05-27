// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFRoyalT2 is ERC721URIStorage, Ownable {
    using Strings for uint256;

    uint256 public tokenCounter;
    address payable public immutable creator;
    uint256 public immutable fixedRoyalty;
    uint256 public royaltyPercentage;

    event RoyaltyPaid(address indexed recipient, uint256 amount);
    event NFTTransferred(address indexed from, address indexed to, uint256 tokenId, uint256 salePrice);

    constructor(
        address payable _creator,
        uint256 _fixedRoyalty,
        uint256 _royaltyPercentage,
        address initialOwner
    ) ERC721("NFRoyalT2", "NFR2") Ownable(initialOwner) {
        require(_creator != address(0), "Invalid creator address");
        require(_fixedRoyalty >= 0, "Fixed royalty must be non-negative");
        require(_royaltyPercentage >= 0 && _royaltyPercentage <= 100, "Invalid royalty percentage");

        tokenCounter = 0;
        creator = _creator;
        fixedRoyalty = _fixedRoyalty;
        royaltyPercentage = _royaltyPercentage;
    }

    function createNFT(string memory _tokenURI) public onlyOwner returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        tokenCounter++;
        return newItemId;
    }

    function brokerTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 salePrice
    ) public payable {
        require(msg.value >= salePrice, "Insufficient payment");
        require(ownerOf(tokenId) == from, "Transfer not authorized by owner");

        uint256 royaltyAmountPercentage = (salePrice * royaltyPercentage) / 100;
        uint256 royaltyAmount = royaltyAmountPercentage > fixedRoyalty ? royaltyAmountPercentage : fixedRoyalty;
        require(royaltyAmount <= salePrice, "Royalty exceeds sale price");

        if (royaltyAmount > 0) {
            (bool successRoyalty, ) = creator.call{value: royaltyAmount}("");
            require(successRoyalty, "Royalty transfer failed");
            emit RoyaltyPaid(creator, royaltyAmount);
        }

        uint256 sellerAmount = salePrice - royaltyAmount;
        (bool successSeller, ) = from.call{value: sellerAmount}("");
        require(successSeller, "Transfer to seller failed");

        _transfer(from, to, tokenId);
        emit NFTTransferred(from, to, tokenId, salePrice);
    }

    function setRoyaltyPercentage(uint256 _royaltyPercentage) external onlyOwner {
        require(_royaltyPercentage >= 0 && _royaltyPercentage <= 100, "Invalid royalty percentage");
        royaltyPercentage = _royaltyPercentage;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    receive() external payable {
        // Function to receive Ether. msg.data must be empty
    }

    fallback() external payable {
        // Function to receive Ether. msg.data is not empty
    }
}

