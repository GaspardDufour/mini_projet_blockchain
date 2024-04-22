// SPDX-License-Identifier: MIT
pragma solidity ^0.4.12;

import "./Whitelist.sol";
import "./Ownable.sol";

contract ProductTraceability is Ownable,Whitelist {
    // Structure pour représenter un produit
    struct Product {
        address manufacturer;   // Adresse du fabricant/producteur
        uint256 lotNumber;     // Numéro de lot
        string productName;    // Nom du produit
        uint256 totalQuantity; // Nombre total de produits par lot
        address lastOwner;     // Dernier propriétaire
        uint256 purchaseDate;  // Date d'achat (timestamp)
    }

    // Mapping pour stocker les produits par leur identifiant
    mapping(uint256 => Product) public products;

    // Événement pour suivre le transfert de propriété
    event ProductTransferred(uint256 indexed lotNumber, address indexed from, address indexed to, uint256 timestamp);

    // Modificateur pour restreindre l'accès aux fonctions autorisées
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Caller is not whitelisted");
        _;
    }

    // Fonction pour enregistrer un nouveau produit
    function registerProduct(
        uint256 _lotNumber,
        string _productName,
        uint256 _totalQuantity
    ) external onlyWhitelisted {
        require(products[_lotNumber].manufacturer == address(0), "Product already registered");

        products[_lotNumber] = Product({
            manufacturer: msg.sender,
            lotNumber: _lotNumber,
            productName: _productName,
            totalQuantity: _totalQuantity,
            lastOwner: msg.sender,
            purchaseDate: block.timestamp
        });
    }

    // Fonction pour transférer la propriété d'un produit à un nouvel propriétaire
    function transferProductOwnership(uint256 _lotNumber, address _newOwner) external onlyWhitelisted {
        require(products[_lotNumber].manufacturer != address(0), "Product does not exist");
        require(products[_lotNumber].lastOwner == msg.sender, "Only current owner can transfer ownership");

        products[_lotNumber].lastOwner = _newOwner;
        emit ProductTransferred(_lotNumber, msg.sender, _newOwner, block.timestamp);
    }
}