/**
 *Submitted for verification at FtmScan.com on 2021-08-24
*/

// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/IRandomNumberGenerator.sol

interface IRandomNumberGenerator {
    /**
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 _seed) external;

    /**
     * View latest bettingId numbers
     */
    function viewLatestBettingId() external view returns (uint256);

    /**
     * Views random result
     */
    function viewRandomResult() external view returns (uint32);
}

interface IRoyalBetting {
    /**
     * @notice Buy tickets for the current betting
     * @param _bettingId: bettingId
     * @param _ticketNumber: ticket number
     * @param placeKind: place kind
     * @dev Callable by users
     */
    function buyTickets(uint256 _bettingId, uint _ticketNumber, uint placeKind) external payable;

    /**
     * @notice Claim a set of winning tickets for a betting
     * @param _bettingId: betting id
     * @param _ticketIds: array of ticket ids
     @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _bettingId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external;

    /**
     * @notice Close betting
     * @param _bettingId: betting id
     * @dev Callable by operator
     */
    function closeBetting(uint256 _bettingId) external;

    /**
     * @notice Start the betting
     * @dev Callable by operator
     * @param _priceInWinningPlace: price of a ticket in ETH WinningPlace
     * @param _priceInThirdPlace: price of a ticket in ETH One-ThirdPlace
     */
    function startBetting(
        uint256 _priceInWinningPlace,
        uint256 _priceInThirdPlace
    ) external;

    /**
     * @notice View current betting id
     */
    function viewcurrentBettingId() external returns (uint256);
}

interface RandomNumberGenerator {
    function setRoyalBetting(address _royalBetting) external;
    function setFee(uint256 _fee) external;
    function setKeyHash(bytes32 _keyHash) external;
}

// File: contracts/BloqBallSwapBetting.sol

pragma abicoder v2;

/**@title RoyalBetting.
 * @notice It is a contract for a betting system using
 * randomness provided externally.
 */
contract RoyalBetting is ReentrancyGuard, IRoyalBetting, Ownable {
    using SafeERC20 for IERC20;

    address public operatorAddress;

    uint256 public currentBettingId;
    uint256 public currentTicketId;

    uint256 public constant WINNING_PLACE = 1; 
    uint256 public constant FIRST_THIRD_PLACE = 2;
    uint256 public placePeriod = 15 * 60;          //1 days;
    uint256 public limitClaimablePeriod = 30 * 60;      //3 days;

    uint256 public ownerTransferAmountRate = 2000;      // 20%

    bool    private enableChainlinkRandomGenerator = false;

    IRandomNumberGenerator public randomGenerator;
    mapping(uint => bool) private randomNumbersMatch;
    uint256 public randomGeneratedNumber;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Betting {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceInWinningPlace;
        uint256 priceInThirdPlace;
        uint256[2] rewardsBreakdown;        // 0: 6500(65%), 1: 2500(25%)
        uint256[2] ETHPerBracket;
        uint256[2] countWinnersPerBracket;
        uint256 firstTicketId;
        uint256 firstTicketIdNextBetting;
        uint256 amountCollectedInETH;
        uint256 finalNumber;
        uint256 amountOfPurchasedPeople;
        uint256 amountOfNotClaimed;
    }

    struct Ticket {
        uint256 number;
        address owner;
    }

    mapping(uint256 => Betting) public _bettings;
    mapping(uint256 => Ticket) public _tickets;

    // Keeps track of number of ticket per each bettingId
    mapping(uint256 => mapping(uint256 => uint256)) public _numberTicketsPerBettingId;

    // Keep track of user ticket ids for a given bettingId
    mapping(address => mapping(uint256 => uint256[])) public _userTicketIdsPerBettingId;
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public _isUserTicketIdsPerBettingId;
    
   // Keep track of user wining rewards for a given bettingId
    mapping(address => mapping(uint256 => uint256)) public _userWiningRewardsPerBettingId;
    
    mapping(uint => mapping(uint => address[])) public _selectedAddressForWinningPlace;
    mapping(uint => mapping(uint => address[])) public _selectedAddressForThirdPlace;
    
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    event BettingClose(uint256 indexed bettingId, uint256 firstTicketIdNextBetting);
    event BettingOpen(
        uint256 indexed bettingId,
        uint256 startTime,
        uint256 endTime,
        uint256 firstTicketId
    );
    event BettingNumberDrawn(uint256 indexed bettingId, uint256 finalNumber);
    event NewOperatorAddresses(address operator);
    event NewRandomGenerator(address indexed randomGenerator);
    event TicketsPurchase(address indexed buyer, uint256 indexed bettingId);
    event TicketsClaim(address indexed claimer, uint256 amount, uint256 indexed bettingId, uint256 numberTickets);

    /**
     * @notice Constructor
     * @dev
     */
    constructor() {
        operatorAddress = msg.sender;
    }

    /**
     * @notice Generate tickets number for the current buyer
     * @dev Callable by users
     */
    function generateRacingNumber() public onlyOperator returns (uint256 racingNumber){
        uint _itemNumber;

        racingNumber = 0;
        bool bEqual;
        uint index;
        
        for (uint i = 0; i < 10; i++)
        {
            randomNumbersMatch[i+1] = false;
        }
        
        for (uint i = 0; i < 10; i++)
        {
            bEqual = true;
            while (bEqual)
            {
                if (enableChainlinkRandomGenerator)
                {
                    // Request a random number from the generator based on a seed
                    randomGenerator.getRandomNumber(uint256(keccak256(abi.encodePacked(currentBettingId, currentTicketId + index + i))));
                    require(currentBettingId == randomGenerator.viewLatestBettingId(), "Numbers not drawn");
                    
                    // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
                    _itemNumber = randomGenerator.viewRandomResult() % 10 + 1;                   
                }
                else
                    _itemNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, index + i))) % 10 + 1;
                    
                if (randomNumbersMatch[_itemNumber])
                    bEqual = true;
                else
                {
                    bEqual = false;
                    randomNumbersMatch[_itemNumber] = true;
                }

                index++;
            }

            racingNumber += _itemNumber * uint256(10)**(i*2);
        }
        
        randomGeneratedNumber = racingNumber;
    }
    
    /**
     * @param _randomGeneratorAddress: address of the RandomGenerator contract used to work with ChainLink VRF
     * @dev Callable by users
     */
    function setRandomGenerator(address _randomGeneratorAddress) public onlyOperator {
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);
        RandomNumberGenerator(_randomGeneratorAddress).setRoyalBetting(address(this));
        
        enableChainlinkRandomGenerator = true;
    }
    
    /**
     * @notice Buy tickets for the current betting
     * @param _bettingId: bettingId
     * @param _ticketNumber: ticket numbers between 1, 10
     * @param _placeKind:kind of place
     * @dev Callable by users
     */
    function buyTickets(uint256 _bettingId, uint _ticketNumber, uint _placeKind)
        external
        payable
        override
        notContract
        nonReentrant
    {
        require(_bettings[_bettingId].status == Status.Open, "Betting is not open");
        require(block.timestamp < _bettings[_bettingId].endTime, "Betting is over");
        require(_placeKind == WINNING_PLACE || _placeKind == FIRST_THIRD_PLACE, "_placeKind is wrong");

        uint newTicketNumber;
        if (_placeKind == WINNING_PLACE)
            newTicketNumber = _ticketNumber * (10 ** 2);
        else if (_placeKind == FIRST_THIRD_PLACE)
            newTicketNumber = _ticketNumber;

        require(!_isUserTicketIdsPerBettingId[msg.sender][_bettingId][newTicketNumber], "This number is already bought for this place");

        if (_placeKind == WINNING_PLACE)
        {
            require(msg.value == _bettings[_bettingId].priceInWinningPlace, "Price is error.");
            _bettings[_bettingId].amountCollectedInETH += _bettings[_bettingId].priceInWinningPlace;
            _selectedAddressForWinningPlace[_bettingId][newTicketNumber].push(msg.sender);
        }
        else
        {
            require(msg.value == _bettings[_bettingId].priceInThirdPlace, "Price is error.");
            _bettings[_bettingId].amountCollectedInETH += _bettings[_bettingId].priceInThirdPlace;
            _selectedAddressForThirdPlace[_bettingId][newTicketNumber].push(msg.sender);
        }
        
        if (_userTicketIdsPerBettingId[msg.sender][_bettingId].length == 0)
            _bettings[_bettingId].amountOfPurchasedPeople++;

        _numberTicketsPerBettingId[_bettingId][newTicketNumber]++;

        _userTicketIdsPerBettingId[msg.sender][_bettingId].push(currentTicketId);

        _isUserTicketIdsPerBettingId[msg.sender][_bettingId][newTicketNumber] = true;

        _tickets[currentTicketId] = Ticket({number: newTicketNumber, owner: msg.sender});

        currentTicketId++;

        emit TicketsPurchase(msg.sender, _bettingId);
    }
     
    /**
     * @notice Get the ticket id and matching number of the numbers
     * @param _bettingId: bettingId
     * @param _account: address of a player
     * @dev Callable by users
     */
    function getBracketsOfMatching(
        uint256 _bettingId, address _account
    )
    external view
    returns (uint256[] memory new_ticketIds, uint256[] memory new_brackets, uint256 pendingRewards)
    {
        uint256[] memory _ticketIds = _userTicketIdsPerBettingId[_account][_bettingId];
        uint ticketLength = _userTicketIdsPerBettingId[_account][_bettingId].length;

        uint32[] memory _brackets = new uint32[](ticketLength);
        bool[] memory ticketStatus;
        uint256[] memory ticketNumbers;
        
        (ticketNumbers, ticketStatus) = viewNumbersAndStatusesForTicketIds(_ticketIds);

        uint256 _winningNumber = _bettings[_bettingId].finalNumber;
        uint256[] memory candidatedNumber = new uint256[](3);
        
        calculateRacingResult(candidatedNumber, _winningNumber);
        
        // Loops through all wimming numbers
        uint index;
        for (uint i = 0; i < ticketLength; i++)
        {
            if (ticketStatus[i] == true)
            {
                _brackets[i] = 0;        // 0%
                continue;
            }

            if (ticketNumbers[i] >= 100)
            {
                if (ticketNumbers[i] == candidatedNumber[0] * (10 ** 2))
                {
                    _brackets[i] = 1;
                    index++;
                }
            }
            else{
                if (ticketNumbers[i] == candidatedNumber[0] || ticketNumbers[i] == candidatedNumber[1] 
                    || ticketNumbers[i] == candidatedNumber[2])
                {
                    _brackets[i] = 2;
                    index++;
                }
            }
        }

        new_brackets = new uint256[](index);
        new_ticketIds = new uint256[](index);
        
        index = 0;
        for (uint i = 0; i < ticketLength; i++)
        {
            if (_brackets[i] == 0)
                continue;

            new_brackets[index] = _brackets[i];
            new_ticketIds[index] = _ticketIds[i];

            index++;
            
            pendingRewards += _calculateRewardsForTicketId(_bettingId, _ticketIds[i], _brackets[i]);
        }
    }
    
    /**
     * @notice Claim a set of winning tickets for a betting
     * @param _bettingId: betting id
     * @param _ticketIds: array of ticket ids
     * @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _bettingId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external override notContract nonReentrant {
        require(_bettings[_bettingId].status == Status.Claimable, "Betting not claimable");
        require(block.timestamp <= _bettings[_bettingId].endTime + limitClaimablePeriod, "Claimable period is ended.");

        // Initializes the rewardInETHToTransfer
        uint256 rewardInETHToTransfer;
        uint256 rewardForTicketId;
        for (uint256 i = 0; i < _ticketIds.length; i++) {
            uint256 thisTicketId = _ticketIds[i];

            require(_bettings[_bettingId].firstTicketIdNextBetting > thisTicketId, "TicketId too high");
            require(_bettings[_bettingId].firstTicketId <= thisTicketId, "TicketId too low");
            require(msg.sender == _tickets[thisTicketId].owner, "Not the owner");

            // Update the betting ticket owner to 0x address
            _tickets[thisTicketId].owner = address(0);

            rewardForTicketId = _calculateRewardsForTicketId(_bettingId, thisTicketId, _brackets[i]);
            
            // Check user is claiming the correct bracket
            require(rewardForTicketId != 0, "No prize for this bracket");

            // Increment the reward to transfer
            rewardInETHToTransfer += rewardForTicketId;
        }

        // Transfer money to msg.sender
        require(payable(msg.sender).send(rewardInETHToTransfer));

        _bettings[_bettingId].amountOfNotClaimed -= rewardInETHToTransfer;
        
        _userWiningRewardsPerBettingId[msg.sender][_bettingId] += rewardInETHToTransfer;
        
        emit TicketsClaim(msg.sender, rewardInETHToTransfer, _bettingId, _ticketIds.length);
    }

    /**
     * @notice Close betting
     * @param _bettingId: betting id
     * @dev Callable by operator
     */
    function closeBetting(uint256 _bettingId) public override onlyOperator nonReentrant {
        require(_bettings[_bettingId].status == Status.Open, "Betting not open");
        require(block.timestamp > _bettings[_bettingId].endTime, "Betting not over");

        _bettings[_bettingId].firstTicketIdNextBetting = currentTicketId;

        if (enableChainlinkRandomGenerator)
        {
            // Request a random number from the generator based on a seed
            randomGenerator.getRandomNumber(uint256(keccak256(abi.encodePacked(_bettingId, currentTicketId))));
        }

        _bettings[_bettingId].status = Status.Close;
        
        drawRacingNumberAndMakeBettingClaimable(_bettingId);

        emit BettingClose(_bettingId, currentTicketId);
    }
    
    /**
     * @notice Check betting state
     * @dev Callable by operator
     */
     function checkBettingState() external onlyOperator{
        if (currentBettingId == 0)
            return;
            
        if (block.timestamp >= _bettings[currentBettingId].endTime 
        && _bettings[currentBettingId].status == Status.Open)
        {
            closeBetting(currentBettingId);
//          drawRacingNumberAndMakeBettingClaimable(currentBettingId);
        }

        if (block.timestamp >= _bettings[currentBettingId].endTime + limitClaimablePeriod
            && _bettings[currentBettingId].status == Status.Claimable
            && _bettings[currentBettingId].amountOfNotClaimed > 0)
        {
            require(payable(owner()).send(_bettings[currentBettingId].amountOfNotClaimed));
            _bettings[currentBettingId].amountOfNotClaimed = 0;
        }
        
        if (block.timestamp >= _bettings[currentBettingId].endTime
            && _bettings[currentBettingId].status == Status.Claimable)
        {
            startBetting(_bettings[currentBettingId].priceInWinningPlace, _bettings[currentBettingId].priceInThirdPlace);
        }
    }
     
    /**
     * @notice Draw the final number, calculate reward in ETH per group, and make betting claimable
     * @param _bettingId: betting id
     * @dev Callable by operator
     */
    function drawRacingNumberAndMakeBettingClaimable(uint256 _bettingId)
        internal
    {
        require(_bettings[_bettingId].status == Status.Close, "Betting not close");
        
        uint256 finalNumber;
        if (enableChainlinkRandomGenerator)
        {
            require(_bettingId == randomGenerator.viewLatestBettingId(), "Numbers not drawn");

            // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
            finalNumber = randomGenerator.viewRandomResult();
        }
        else
            finalNumber = generateRacingNumber();

        // Calculate the amount to share post-treasury fee
        uint256 amountToOwner = ownerTransferAmountRate * _bettings[_bettingId].amountCollectedInETH / 10000;
        uint256 amountToShareToWinners = _bettings[_bettingId].amountCollectedInETH - amountToOwner;

        uint[] memory candidatedNumber = new uint[](3);
        
        calculateRacingResult(candidatedNumber, finalNumber);

        _bettings[_bettingId].countWinnersPerBracket[0] =
                _numberTicketsPerBettingId[_bettingId][candidatedNumber[0] * (10 ** 2)];

        _bettings[_bettingId].countWinnersPerBracket[1] =
                _numberTicketsPerBettingId[_bettingId][candidatedNumber[0]] + 
                _numberTicketsPerBettingId[_bettingId][candidatedNumber[1]] +
                _numberTicketsPerBettingId[_bettingId][candidatedNumber[2]];

        for (uint32 i = 0; i < 2; i++) {
            if (_bettings[_bettingId].countWinnersPerBracket[i] == 0)
                _bettings[_bettingId].ETHPerBracket[i] = 0;
            else
                _bettings[_bettingId].ETHPerBracket[i] =
                        ((_bettings[_bettingId].rewardsBreakdown[i] * amountToShareToWinners) /
                            _bettings[_bettingId].countWinnersPerBracket[i]) / 10000;
        }

        // Update internal statuses for betting
        _bettings[_bettingId].finalNumber = finalNumber;
        _bettings[_bettingId].status = Status.Claimable;

        _bettings[_bettingId].amountOfNotClaimed = amountToShareToWinners;

        // Send 20% of accumulated ETHs to owner
        require(payable(owner()).send(amountToOwner));

        emit BettingNumberDrawn(currentBettingId, finalNumber);
    }
    
    /**
     * @notice Change the random generator
     * @dev The calls to functions are used to verify the new generator implements them properly.
     * It is necessary to wait for the VRF response before starting a round.
     * Callable only by the contract owner
     * @param _randomGeneratorAddress: address of the random generator
     */
    function changeRandomGenerator(address _randomGeneratorAddress) external onlyOperator {
        require(_bettings[currentBettingId].status == Status.Claimable, "Betting not in claimable");

        // Request a random number from the generator based on a seed
        IRandomNumberGenerator(_randomGeneratorAddress).getRandomNumber(
            uint256(keccak256(abi.encodePacked(currentBettingId, currentTicketId)))
        );

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        IRandomNumberGenerator(_randomGeneratorAddress).viewRandomResult();

        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    /**
     * @notice Start the betting
     * @dev Callable by operator
     * @param _priceInWinningPlace: price of a ticket in ETH WinningPlace
     * @param _priceInThirdPlace: price of a ticket in ETH One-ThirdPlace
     */
    function startBetting(
        uint256 _priceInWinningPlace,
        uint256 _priceInThirdPlace
    ) public override onlyOperator {
        require(
            (currentBettingId == 0) || (_bettings[currentBettingId].status == Status.Claimable),
            "Not time to start betting"
        );
      
        currentBettingId++;

        _bettings[currentBettingId] = Betting({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: block.timestamp + placePeriod,
            priceInWinningPlace: _priceInWinningPlace,
            priceInThirdPlace: _priceInThirdPlace,
            rewardsBreakdown: [uint256(6500), uint256(3500)],
            ETHPerBracket: [uint256(0), uint256(0)],
            countWinnersPerBracket: [uint256(0), uint256(0)],
            firstTicketId: currentTicketId,
            firstTicketIdNextBetting: currentTicketId,
            amountCollectedInETH: 0,
            finalNumber: 0,
            amountOfPurchasedPeople:0,
            amountOfNotClaimed:0
        });

        emit BettingOpen(
            currentBettingId,
            block.timestamp,
            block.timestamp + placePeriod,
            currentTicketId
        );
    }
  
    /**
     * @notice Set operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function setOperator(
        address _operatorAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");

        operatorAddress = _operatorAddress;

        emit NewOperatorAddresses(_operatorAddress);
    }
    
    /**
     * @notice Get operator addresses
     */
    function getOperator() external view returns (address) {
        return operatorAddress;
    }

    /**
     * @notice Set place period
     * @dev Only callable by owner
     * @param _placePeriod: period of the place
     */
    function setPlacePeriod(uint _placePeriod) external onlyOwner {
        placePeriod = _placePeriod;
    }

    /**
     * @notice View current betting id
     */
    function viewcurrentBettingId() external view override returns (uint256) {
        return currentBettingId;
    }

    /**
     * @notice View betting information
     * @param _bettingId: betting id
     */
    function viewBetting(uint256 _bettingId) external view returns (Betting memory) {
        return _bettings[_bettingId];
    }

    /**
     * @notice View ticker statuses and numbers for an array of ticket ids
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndStatusesForTicketIds(uint256[] memory _ticketIds)
        public
        view
        returns (uint256[] memory, bool[] memory)
    {
        uint256 length = _ticketIds.length;
        uint256[] memory ticketNumbers = new uint256[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketNumbers[i] = _tickets[_ticketIds[i]].number;
            if (_tickets[_ticketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                ticketStatuses[i] = false;
            }
        }

        return (ticketNumbers, ticketStatuses);
    }

    /**
     * @notice View rewards for a given ticket, providing a bracket, and betting id
     * @dev Computations are mostly offchain. This is used to verify a ticket!
     * @param _bettingId: betting id
     * @param _ticketId: ticket id
     */
    function viewRewardsForTicketId(
        uint256 _bettingId,
        uint256 _ticketId,
        uint32 _bracket
        
    ) external view returns (uint256) {
        // Check betting is in claimable status
        if (_bettings[_bettingId].status != Status.Claimable) {
            return 0;
        }

        // Check ticketId is within range
        if (
            (_bettings[_bettingId].firstTicketIdNextBetting < _ticketId) &&
            (_bettings[_bettingId].firstTicketId >= _ticketId)
        ) {
            return 0;
        }

        return _calculateRewardsForTicketId(_bettingId, _ticketId, _bracket);
    }

    /**
     * @notice Calculate rewards for a given ticket
     * @param _bettingId: betting id
     * @param _ticketId: ticket id
     * @param _bracket: 
     */
    function _calculateRewardsForTicketId(
        uint256 _bettingId,
        uint256 _ticketId,
        uint256 _bracket
    ) public  view returns (uint256) {
        if (_bracket == 0)
            return 0;
            
        // Retrieve the winning number combination
        uint256 winningNumber = _bettings[_bettingId].finalNumber / (10 ** 18);

        // Retrieve the user number combination from the ticketId
        uint256 userNumber = _tickets[_ticketId].number;

        // Confirm that the two transformed numbers are the same, if not throw
        if (_bracket == 1)
        {
            if (userNumber == winningNumber * (10 ** 2)) {
                return _bettings[_bettingId].ETHPerBracket[_bracket - 1];
            } else {
                return 0;
            }
        }
        else if (_bracket == 2)
        {
            uint256[] memory candidatedNumber = new uint256[](3);
            
            calculateRacingResult(candidatedNumber, _bettings[_bettingId].finalNumber);
            
            if (userNumber == candidatedNumber[0] 
                || userNumber == candidatedNumber[1] 
                || userNumber == candidatedNumber[2])
                return _bettings[_bettingId].ETHPerBracket[_bracket - 1];
            else
                return 0;
        }
        
        return 0;
    }
    
    /**
     * @notice Calculate racing result
     * @param candidatedNumber: array of 1st, 2nd, 3rd horse numbers
     * @param winningNumber: result of horse racing
     */
    function calculateRacingResult(uint256[] memory candidatedNumber, uint256 winningNumber) 
        public 
        pure
    {
        uint number;
        for (uint j = 10; j > 7; j--) {
            number = winningNumber / (10 ** ((j-1)*2));
            winningNumber = winningNumber % (10 ** ((j-1)*2));

            candidatedNumber[10-j] = number;
        }
    }
    
    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery
     * @param _user: user address
     * @param _bettingId: Betting id
     * @param _place: place kind
     */
    function viewUserInfoForBettingId(
        address _user,
        uint256 _bettingId,
        uint _place
    )
        external
        view
        returns (uint256[] memory)
    {
        uint256 length = _userTicketIdsPerBettingId[_user][_bettingId].length;

        uint256[] memory bettingTicketIds = new uint256[](length);

        uint index;
        for (uint256 i = 0; i < length; i++) {
            bettingTicketIds[i] = _userTicketIdsPerBettingId[_user][_bettingId][i];
            
            if (_place == WINNING_PLACE )
            {
                if (_tickets[bettingTicketIds[i]].number >= 100)
                {
                    index++;
                }
            }
            else
            {
                if (_tickets[bettingTicketIds[i]].number < 100)
                {
                    index++;
                }
            }
        }
        
        uint256[] memory ticketNumbers = new uint256[](index);
        
        index = 0;
        for (uint256 i = 0; i < length; i++) {
            bettingTicketIds[i] = _userTicketIdsPerBettingId[_user][_bettingId][i];
            
            if (_place == WINNING_PLACE )
            {
                if (_tickets[bettingTicketIds[i]].number >= 100)
                {
                    ticketNumbers[index] = _tickets[bettingTicketIds[i]].number / (10 ** 2);   
                    index++;
                }
            }
            else
            {
                if (_tickets[bettingTicketIds[i]].number < 100)
                {
                    ticketNumbers[index] = _tickets[bettingTicketIds[i]].number;
                    index++;
                }
            }
        }

        return (ticketNumbers);
    }
    
    /**
     * @notice View winners info
     * @param _bettingId: _betting id
     */
    function viewWinnersInfo(uint256 _bettingId)
        external
        view
        returns (address[] memory winners1, address[] memory winners2)
    {
        require(_bettings[_bettingId].status == Status.Claimable, "Betting not claimable");
        
        uint256[] memory candidatedNumber = new uint256[](3);
        
        calculateRacingResult(candidatedNumber, _bettings[_bettingId].finalNumber);
        
        uint nlengthOfWinner1 = _selectedAddressForWinningPlace[_bettingId][candidatedNumber[0] * (10 ** 2)].length;
        
        uint nlengthOfWinner2 = _selectedAddressForThirdPlace[_bettingId][candidatedNumber[0]].length; 
        uint nlengthOfWinner3 = _selectedAddressForThirdPlace[_bettingId][candidatedNumber[1]].length;
        uint nlengthOfWinner4 = _selectedAddressForThirdPlace[_bettingId][candidatedNumber[2]].length;
                                
        winners1 = new address[](nlengthOfWinner1);
        
        winners1 = _selectedAddressForWinningPlace[_bettingId][candidatedNumber[0] * (10 ** 2)];
        
        winners2 = new address[](nlengthOfWinner2 + nlengthOfWinner3 + nlengthOfWinner4);
        
        for (uint i=0; i<nlengthOfWinner2; i++)
        {
            winners2[i] = _selectedAddressForThirdPlace[_bettingId][candidatedNumber[0]][i];
        }
        
        for (uint i=nlengthOfWinner2; i<nlengthOfWinner2 + nlengthOfWinner3; i++)
        {
            winners2[i] = _selectedAddressForThirdPlace[_bettingId][candidatedNumber[1]][i - nlengthOfWinner2];
        }
        
        for (uint i=nlengthOfWinner2 + nlengthOfWinner3; i<nlengthOfWinner2 + nlengthOfWinner3 + nlengthOfWinner4; i++)
        {
            winners2[i] = _selectedAddressForThirdPlace[_bettingId][candidatedNumber[2]][i - nlengthOfWinner2 - nlengthOfWinner3];
        }
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}