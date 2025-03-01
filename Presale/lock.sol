// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;



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
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol



pragma solidity ^0.8.0;

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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/TokenLock.sol



import "./ERC20.sol";


pragma solidity ^0.8.0;
// pragma abicoderv2;

contract TokenTimelock {
    using SafeERC20 for IERC20;
    address public ERC20adr;
    IERC20 _token;
    // beneficiary of tokens after they are released
    address public _beneficiary;
    address OWNER;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    // Fee
    uint256 public adminWalletFee = 0.00696 * 10**9; 
    uint256 public stakingPoolFee = 0;
    uint256 public burnFee = 100 * 10**9;
    uint256 public totalfee = adminWalletFee +stakingPoolFee+burnFee;

    address adminWalletAddress = address(0);
    address stakingPoolAddress = address(0);
    address immutable public SSN = 0x8A6E3213a3351A7F587894f84Fe07C7F86aC7130;
    uint256 public id;
    address launchAddress = address(0);

    constructor(address _adminAddress,address _stakingAddress){
        // update fees addresses
        adminWalletAddress = _adminAddress;
        stakingPoolAddress = _stakingAddress;
        OWNER = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender==OWNER,"Not Allowed");
        _;
    }
     modifier onlyLaunch(){
        require(msg.sender==launchAddress,"Not launch");
        _;
    }

    mapping (address => uint256) _lockTokens;
       

    struct Locks {
       // ERC20 basic token contract being held
        IERC20 Token;

        uint256 Id;
        address Beneficiary;
        // timestamp when token release is enabled
        uint256 ReleaseTime;
        //amount to be locked
        uint256 Amount;
        string Logolink;
        bool Status;
    }
    
    // Locks[] public locks;
    mapping (address => Locks[]) public Owner;

    event LockLog(address token, address user, address beneficiary, uint256 txId, uint256 txTime );
    function lock(
        address token_,
        address beneficiary_,
        uint256 releaseTime_,
        uint256 amount_,
        uint256 period_,
        string memory logoLink_


    ) public {
        address _owner = beneficiary_;
        require (amount_ < IERC20(token_).balanceOf(msg.sender), "Not enough balance");

        uint256 initTime = block.timestamp;
        require(releaseTime_ > initTime, "TokenTimelock: release time is before current time");
        uint  i=0;
        if(period_>1){
            uint256 partTime= (releaseTime_ - block.timestamp)/period_;
            uint256 partAmount = amount_/period_;
            
            for(i=1; i<=period_; i++){
            // Vest storage newVest = Vest(_amount/_period, block.timestamp+i*partTime);
            // Owner[_owner].push(locks(token, beneficiary_, block.timestamp+i*partTime, partAmount ));
            Locks memory locks = Locks(IERC20(token_), id, beneficiary_, initTime+i*partTime, partAmount, logoLink_, false);
            Owner[_owner].push(locks);
            }
        }
        else{
        Locks memory locks = Locks(IERC20(token_), id, beneficiary_, releaseTime_, amount_, logoLink_, false);
            Owner[_owner].push(locks);        
        }
        // IERC20(token_).approve(address(this),  amount_);
         require(amount_ > 0, "You need to lock at least some tokens");
        // IERC20(token_).approve(address(this), amount_);
        uint256 allowance = IERC20(token_).allowance(msg.sender, address(this));

        require(allowance >= amount_, "Check the token allowance");

        IERC20(token_).transferFrom(msg.sender, address(this), amount_);

        // payable(msg.sender).transfer(amount_);
            // IERC20(token_).transfer(address(this), amount_);

            IERC20(SSN).transferFrom(msg.sender, adminWalletAddress, adminWalletFee);
            IERC20(SSN).transferFrom(msg.sender, DEAD, burnFee);
            if(stakingPoolFee!= 0){
                IERC20(SSN).transferFrom(msg.sender, stakingPoolAddress, stakingPoolFee);
            }
        emit LockLog(token_, msg.sender, beneficiary_, id, initTime);
        id++;
        _lockTokens[token_] += amount_;

    }

    function getTransaction(address owner_, uint256 index)public view returns(Locks memory){
        return Owner[owner_][index];
    }
    function getLockTokens(address token_) public view returns(uint256){
        return _lockTokens[token_];
    }

    function getId(address owner_, uint256 index)public view returns(uint256){
        return Owner[owner_][index].Id;
    }
  
    function updateWalletAddress(address _newAdminWallet, address _newStakingWallet, address _newLaunchAddress) public onlyOwner virtual{
        // require(_newAdminWallet != address(0),"ZA");
        adminWalletAddress = _newAdminWallet;
        stakingPoolAddress = _newStakingWallet;
        launchAddress = _newLaunchAddress;
    }
    function updateFee(uint256 adminWalletFee_, uint256 stakingPoolFee_, uint256 burnFee_ )public onlyOwner{
    adminWalletFee = adminWalletFee_;
    stakingPoolFee = stakingPoolFee_;
    burnFee = burnFee_;
    totalfee = adminWalletFee + stakingPoolFee + burnFee;

    }
    // function stakingAddress
    /**
     * @return the token being held.
     */
    function lockLength(address owner_) public view returns (uint){
        return Owner[owner_].length;
    }

    function token(address owner_, uint index) public view returns (IERC20) {
        return Owner[owner_][index].Token;
    }

    function checkAllowance(IERC20 token_, address user) public view returns (uint256){
        return token_.allowance(user, address(this));
    }
    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary(address owner_, uint index) public view returns (address) {
        return Owner[owner_][index].Beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime(address owner_, uint index) public view returns (uint256) {
        return Owner[owner_][index].ReleaseTime;
    }

    function amount(address owner_, uint index) public view returns(uint256){
        return Owner[owner_][index].Amount;
    }


    /**
     * @notice Transfers tokens held by timelock to beneficiary.
    */


    // function release_vest(uint256 index, uint256 id) public {
    //     require(block.timestamp>=Owner[_owner][index].vest[id].vest_time, "TokenTimelock: current time is before release time");
    //     require(Owner[_owner][index].vest[id].vest_amount > 0, "TokenTimelock: no tokens to release");

    //     IERC20(token()).safeTransfer(beneficiary(), Owner[_owner][index].vest[id].vest_amount);

    // }
    function checkBalance(IERC20 token_, address owner_) public view returns (uint){
        return token_.balanceOf(owner_);
    }

     function release(uint index) public  {
        
        require(Owner[msg.sender][index].Status== false, "Token already released");
        // IERC20 e = IERC20(ERC20adr);
        require(block.timestamp >= releaseTime(msg.sender, index), "TokenTimelock: current time is before release time");
        // uint256 bal = checkBalance(msg.sender, index);
        // require (amount(msg.sender, index)<= bal, "Amount must be less than user balance");
        require(amount(msg.sender, index) > 0, "TokenTimelock: no tokens to release");
        token(msg.sender, index).transfer(beneficiary(msg.sender, index), amount(msg.sender, index));
        
        Owner[msg.sender][index].Status = true;
        _lockTokens[address(token(msg.sender, index))] -= amount(msg.sender, index);



    }
}