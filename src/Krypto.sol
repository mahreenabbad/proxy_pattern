// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


import "@openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title KryptoSignatures
 * @dev ERC20 Stablecoin with minting, burning, pausing, and role-based access control
 * @notice This contract implements a stablecoin with administrative controls
 * @notice This contract is UUPS upgradeable
 */
contract KryptoSignatures is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    // Role definitions
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BLACKLIST_ROLE = keccak256("BLACKLIST_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // Maximum supply limit (100 billion tokens with 6 decimals)
    uint256 public MAX_SUPPLY;

    // Blacklist mapping
    mapping(address => bool) public blacklisted;

    // Events
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event MaxSupplyUpdated(uint256 newMaxSupply);
    event CompliantBurnStatement(address indexed Merchant, uint256 BurnValue);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer function that replaces constructor for upgradeable contracts
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param initialOwner The address that will own the contract and have admin roles
     */
    function initialize(string memory name_, string memory symbol_, address initialOwner) public initializer {
        __ERC20_init(name_, symbol_);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
        //__UUPSUpgradeable_init();

        // Grant roles to initial owner
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(MINTER_ROLE, initialOwner);
        transferOwnership(initialOwner);
        _grantRole(PAUSER_ROLE, initialOwner);
        _grantRole(BLACKLIST_ROLE, initialOwner);
        _grantRole(BURNER_ROLE, initialOwner);

        MAX_SUPPLY = 100_000_000_000_000_000 * 10 ** 18;
    }

    function Granting(address Minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, Minter);
    }

    function GrantingMainAdmin(address Admin) external onlyOwner {
        _grantRole(DEFAULT_ADMIN_ROLE, Admin);
    }

    function GrantingPausing(address Pauser) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(PAUSER_ROLE, Pauser);
    }

    function GrantingBlackListing(address Blacklister) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(BLACKLIST_ROLE, Blacklister);
    }

    function GrantingBurning(address Burner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(BURNER_ROLE, Burner);
    }

    /**
     * @dev Mints tokens to specified address
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(to != address(0), "Cannot mint to zero address");
        require(!blacklisted[to], "Cannot mint to blacklisted address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting would exceed max supply");

        _mint(to, amount);
        emit Mint(to, amount);
    }

    /**
     * @dev Burns tokens from specified address (requires allowance or ownership)
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) public override onlyRole(BURNER_ROLE) {
        require(!blacklisted[from], "Cannot burn from blacklisted address");
        super.burnFrom(from, amount);
        emit Burn(from, amount);
    }

    /**
     * @dev Burns tokens from caller's balance
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) public override onlyRole(BURNER_ROLE) {
        require(!blacklisted[msg.sender], "Blacklisted address cannot burn");
        super.burn(amount);
        emit Burn(msg.sender, amount);
    }

    /**
     * @dev Pauses all token transfers
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Adds address to blacklist
     * @param account Address to blacklist
     */
    function blacklist(address account) external onlyRole(BLACKLIST_ROLE) {
        require(account != address(0), "Cannot blacklist zero address");
        require(!blacklisted[account], "Address already blacklisted");

        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Removes address from blacklist
     * @param account Address to remove from blacklist
     */
    function unBlacklist(address account) external onlyRole(BLACKLIST_ROLE) {
        require(blacklisted[account], "Address not blacklisted");

        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

    /**
     * @dev Checks if address is blacklisted
     * @param account Address to check
     * @return bool True if blacklisted
     */
    function isBlacklisted(address account) external view returns (bool) {
        return blacklisted[account];
    }

    /**
     * @dev Override _update to resolve diamond inheritance and add custom logic
     * Must explicitly specify all parent contracts that implement this function
     */
    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        require(!blacklisted[from], "Sender is blacklisted");
        require(!blacklisted[to], "Recipient is blacklisted");

        // Call parent implementations - ERC20Pausable will handle the pause check
        // and also call ERC20's implementation
        super._update(from, to, amount);

        // Emit CompliantBurnStatement event when someone receives ZUSD
        if (to != address(0)) {
            emit CompliantBurnStatement(to, amount);
        }
    }

    /**
     * @dev Authorizes upgrade of the contract (required by UUPS)
     * @param newImplementation Address of the new implementation contract
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {
        // Only DEFAULT_ADMIN_ROLE can authorize upgrades
    }

    /**
     * @dev Emergency function to recover accidentally sent ERC20 tokens
     * @param token Address of the token to recover
     * @param amount Amount of tokens to recover
     */
    function recoverERC20(address token, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        require(token != address(this), "Cannot recover own token");
        IERC20(token).transfer(msg.sender, amount);
    }

    /**
     * @dev Emergency function to recover accidentally sent ETH
     */
    function recoverETH() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Returns current supply information
     */
    function supplyInfo() external view returns (uint256 currentSupply, uint256 maxSupply, uint256 remainingSupply) {
        currentSupply = totalSupply();
        maxSupply = MAX_SUPPLY;
        remainingSupply = MAX_SUPPLY - currentSupply;
    }
}
