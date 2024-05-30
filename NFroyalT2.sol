// src/NFroyalT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFroyalT is ERC721URIStorage, Ownable, ReentrancyGuard {
    uint256 public tokenCounter;
    address payable public immutable creator;
    uint256 public immutable creatorFixedRoyalty;
    uint256 public immutable creatorRoyaltyPercentage;

    struct TokenSaleInfo {
        uint256 salePriceETH;
        SalePriceERC20 salePriceERC20;
    }

    struct SalePriceERC20 {
        string name;
        string symbol;
        string chain;
        address contractAddress;
        uint256 salePrice;
    }

    struct RoyaltyInfo {
        address payable recipient;
        uint256 percentage;
        uint256 fixedAmount;
    }

    mapping(uint256 => TokenSaleInfo) private tokenSalePrices;
    mapping(uint256 => RoyaltyInfo[]) private royalties;

    event RoyaltyPaid(address indexed recipient, uint256 amount);  // Make sure this is defined correctly
    event NFTTransferred(address indexed from, address indexed to, uint256 tokenId, uint256 salePrice);
    event ERC20Deposited(address indexed token, address indexed from, uint256 amount);
    event ERC20Withdrawn(address indexed token, address indexed to, uint256 amount);
    event SalePriceSetETH(uint256 indexed tokenId, uint256 salePrice);
    event SalePriceSetERC20(uint256 indexed tokenId, string name, string symbol, string chain, address contractAddress, uint256 salePrice);
    event RoyaltyAdded(uint256 indexed tokenId, address indexed recipient, uint256 percentage, uint256 fixedAmount);

    constructor(
        address payable _creator,
        uint256 _creatorFixedRoyaltyInEther,
        uint256 _creatorRoyaltyPercentage
    ) ERC721("MarketplaceRoyalty", "NFTMR") Ownable(_creator) {
        require(_creator != address(0), "Invalid creator address");
        require(_creatorRoyaltyPercentage >= 0 && _creatorRoyaltyPercentage <= 100, "Invalid royalty percentage");

        uint256 _creatorFixedRoyalty = _creatorFixedRoyaltyInEther * 1 ether; // Correct conversion to wei

        tokenCounter = 0;
        creator = _creator;
        creatorFixedRoyalty = _creatorFixedRoyalty;
        creatorRoyaltyPercentage = _creatorRoyaltyPercentage;
    }

    // Other functions...

    function brokerTransferETH(
        address from,
        address to,
        uint256 tokenId
    ) public payable nonReentrant {
        uint256 salePrice = tokenSalePrices[tokenId].salePriceETH;
        require(msg.value >= salePrice, "Insufficient payment");
        require(ownerOf(tokenId) == from, "Transfer not authorized by owner");

        RoyaltyInfo[] memory royaltyInfo = royalties[tokenId];
        uint256 totalRoyaltyAmount = 0;

        // Calculate and distribute royalties
        for (uint256 i = 0; i < royaltyInfo.length; i++) {
            uint256 recipientRoyaltyAmount = (salePrice * royaltyInfo[i].percentage) / 100;
            if (recipientRoyaltyAmount < royaltyInfo[i].fixedAmount) {
                recipientRoyaltyAmount = royaltyInfo[i].fixedAmount;
            }
            // Ensure cumulative royalty does not exceed sale price
            if (totalRoyaltyAmount + recipientRoyaltyAmount > salePrice) {
                recipientRoyaltyAmount = salePrice - totalRoyaltyAmount;
            }
            totalRoyaltyAmount += recipientRoyaltyAmount;

            (bool success, ) = royaltyInfo[i].recipient.call{value: recipientRoyaltyAmount}("");
            require(success, "Royalty transfer failed");
            emit RoyaltyPaid(royaltyInfo[i].recipient, recipientRoyaltyAmount);  // Emit the event here

            // Stop distribution if sale price is fully consumed
            if (totalRoyaltyAmount >= salePrice) {
                break;
            }
        }

        // Transfer remaining amount to the seller
        uint256 sellerAmount = salePrice - totalRoyaltyAmount;
        (bool successSeller, ) = from.call{value: sellerAmount}("");
        require(successSeller, "Transfer to seller failed");

        _transfer(from, to, tokenId);
        emit NFTTransferred(from, to, tokenId, salePrice);

        // Add the new owner to the royalty list
        royalties[tokenId].push(RoyaltyInfo({
            recipient: payable(to),
            percentage: 0,
            fixedAmount: 0
        }));
    }
}

