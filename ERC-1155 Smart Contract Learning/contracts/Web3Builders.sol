// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Web3Builders is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter {
    uint256 public publicPrice = 0.02 ether;    // This is converted to wei
    uint256 public alllowListPrice = 0.01 ether;
    uint256 public maxSupply = 20;
    uint256 public maxPerWallet = 3;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping (address => bool) public allowList;
    mapping (address => uint256) public purchasesPerWallet;

    constructor(address initialOwner, address[] memory _payees, uint256[] memory _shares)
        ERC1155("ipfs://QmVeNBBT3bA6CfChGq9sM2Ts98kqLGt4JUrHKsFqVww7Vq/")
        Ownable(initialOwner)
        PaymentSplitter(_payees, _shares)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Add supply tracking
    function publicMint(uint256 id, uint256 amount)
        public payable 
    {
        require(publicMintOpen, "Public mint closed");
        internalMint(id, amount);
        require(msg.value == publicPrice * amount, "Wrong! Not enough money sent");
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(exists(_id), "URI : nonexistent token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));    // abi.encodePacked combines different strings together
    }

    function withDraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;    // Get the balance of the contract
        payable(_addr).transfer(balance);
    }

    function allowListMint(uint256 id, uint256 amount) external payable {
        require(allowListMintOpen, "Allow list mint is closed");
        require(allowList[msg.sender], "You are not on the allow list to mint");
        require(msg.value == alllowListPrice * amount, "Wrong! Not enough money sent");
        internalMint(id, amount);
    }

    function internalMint(uint256 id, uint256 amount) internal {
        require(purchasesPerWallet[msg.sender] + amount <= maxPerWallet, "Wallet limit reached");
        require(id < 2, "Sorry looks like you are trying to mint the wrong NFT");
        require(totalSupply(id) + amount <= maxSupply, "Sorry we have minted out");
        _mint(msg.sender, id, amount, "");
        purchasesPerWallet[msg.sender] += amount; 
    }

    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    function setAllowList(address[] calldata _addresses) external onlyOwner {
        for(uint256 i=0; i<_addresses.length; i++) {
            allowList[_addresses[i]] = true;
        }
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
