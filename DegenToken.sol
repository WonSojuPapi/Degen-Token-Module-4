// SPDX-License-Identifier: MIT
/*
1. Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
2. Transferring tokens: Players should be able to transfer their tokens to others.
3. Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
4. Checking token balance: Players should be able to check their token balance at any time.
5. Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/
pragma solidity >=0.6.12 <0.9.0;

contract DegenToken {
    string public name;
    string public symbol;
    string public showStoreItems;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) private balances;
    mapping(uint256 => uint256) public StorePrices;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private isAdmin;
    mapping(address => uint256) private rewards;

    event TokensTransferred(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event RewardAdded(address indexed admin, uint256 amount);
    event RewardRedeemed(address indexed player, uint256 amount);

    constructor() {
        owner = msg.sender;
        // Store Item Prices
        StorePrices[1] = 1000;
        StorePrices[2] = 750;
        StorePrices[3] = 500;
        StorePrices[4] = 100;
        name = "Degen Token";
        symbol = "DGN";
        showStoreItems = "The items on sale: {1} Degen In-Game BattlePass (1000) {2} Degen In-Game BundlePack (750) {3} Degen In-Game Skin (500) {4} Degen In-Game Spray (100)";
        decimals = 18;
        totalSupply = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");

        balances[account] += amount;
        totalSupply += amount;

        emit TokensTransferred(address(0), account, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit TokensTransferred(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(sender != address(0), "Invalid address");
        require(recipient != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit TokensTransferred(sender, recipient, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function redeem(uint256 _item) public {
        require(StorePrices[_item] > 0, "Item is not available.");
        require(_item <= 4, "Item is not available.");
        require(balances[msg.sender] >= StorePrices[_item], "Redeem Failed: Insufficient Balance.");

        _transfer(msg.sender, owner, StorePrices[_item]);
    }

            function burn(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit TokensTransferred(msg.sender, address(0), amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Invalid sender address");
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Invalid transfer amount");
        require(amount <= balances[sender], "Insufficient balance");

        balances[sender] -= amount;
        balances[recipient] += amount;

        emit TokensTransferred(sender, recipient, amount);
    }

        function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Invalid address");

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }
}
