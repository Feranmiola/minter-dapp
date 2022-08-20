// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.8.10;

// import "./Ownable.sol";
import "./ICO.sol";

interface IICO{
    function cancelPresale() external;
    function setIsKYCAndAudit(bool kyc,bool audit) external;
     function requestKYCandAudit() external view returns(address);
}

contract Launch {
    using SafeMath for uint256;
    mapping(uint256 => ICOBase) public icoList;
    mapping(address => ICOBase) public icoAddressList;

    mapping(address => mapping(uint256=>uint256)) _userIcoData;
    mapping(address => uint256) public _userIcoCount;

    ICOBase[] public ongoingIcos;
    ICOBase[] public endedIcos;
    address owner;
    
    // Track the number of ico launched
    uint256 public lastIndex = 0;

    mapping(address => bool) updatePermitted;
    
    // mapping(address=>bool) public _canUpdate;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    // Fee
    uint256 public adminWalletFee = 3000 * 10**18; 
    uint256 public stakingPoolFee = 0;
    uint256 public burnFee = 100 * 10**18;
    //// Post ICO Fees
    uint256 feesBNBPercent = 200; // two decimal places there;
    uint256 ICOAdminWalletFees = 200; // two decimal places;
    uint256 ICOStakingPoolFees = 0; // two decimal places;
    // Burn Tracker
    uint256 totalBurned = 0;

    // Fee collection address
    address adminWalletAddress = address(0);
    address stakingPoolAddress = address(0);

    
    function owners() internal view{
        require(owner == msg.sender);
    }

    // Supersonic token Addresss
    // address immutable public SSN = 0x89d453108bD94B497bBB4496729cd26f92Aba533;
    address immutable public SSN = 0x5D78cde7106732BC0B1CEF6C63637595C28DfCEb;

    event PresaleCreated(address indexed created, address indexed token);

    constructor(address _adminAddress,address _stakingAddress){
        // update fees addresses
        adminWalletAddress = _adminAddress;
        stakingPoolAddress = _stakingAddress;
        owner = msg.sender;
        updatePermitted[msg.sender];
    }

    function giveOrRemoveAccess(address user_,bool isGiving) public {
        owners();
        updatePermitted[user_] = isGiving;
    }

    // Update Everything
    function updateWalletAddress(address _newAdminWallet, address _newStakingPoolAddress) public virtual{
        owners();
        // require(_newAdminWallet != address(0),"ZA");
        adminWalletAddress = _newAdminWallet;
        stakingPoolAddress = _newStakingPoolAddress;
    }
    function cancelPresale(address presaleAddress) public virtual{
        owners();
        IICO(presaleAddress).cancelPresale();
    }
    // Update fees
    // Create New ICO takes many Argument be cautious to provide all of them while calling
    function createNewICO(DataParam calldata newICOData) public virtual{
        // Create details
        IERC20 token = IERC20(newICOData.tokenAddress);
        lastIndex = lastIndex.add(1);
        ICOparam memory _icoBase = _makeICOObject(lastIndex,newICOData);
        ICO icoContract = new ICO(_icoBase);
        // uint256 usrICOcount = _userIcoCount[msg.sender] + 1;

        // setLiquidityPair
        try icoContract.setPairAddress(){}
        catch{
            icoContract.getPairAddress();
        }
        // Update Creator
        // _userIcoCount[msg.sender] = usrICOcount;
        // _userIcoData[msg.sender][usrICOcount] = lastIndex;

        // Transfer Tokens
        IERC20 ssn = IERC20(SSN);
        totalBurned = totalBurned.add(burnFee);
        ssn.transferFrom(msg.sender, adminWalletAddress, adminWalletFee);
        if(stakingPoolFee != 0){
            ssn.transferFrom(msg.sender, stakingPoolAddress, stakingPoolFee);
        }
        ssn.transferFrom(msg.sender, DEAD, burnFee);

        // Transfer Token
        token.transferFrom(msg.sender, address(icoContract), _totalFees(newICOData.liquiditySupply, newICOData.exchangeListingRateBNB, newICOData.hardCap, newICOData.presaleSupply));
        
        // Create New ICO
        _createAndAssign(_icoBase,icoContract);

        emit PresaleCreated(address(icoContract),newICOData.tokenAddress);
    }
    function _createAndAssign(ICOparam memory icoParam, ICO icoContract) internal {
        ICOBase memory _ico = ICOBase(address(icoContract),icoParam);
        ongoingIcos.push(_ico);
        icoAddressList[address(icoContract)] = _ico;
    }

    function getAnIco(address presale) public view returns(ICOBase memory){
        return icoAddressList[presale];
    }

    function updateKYCAndnAudit(address presale,bool kyc,bool audit) public{
        require(updatePermitted[msg.sender],"Action Not Allowed");
        IICO ico_ = IICO(presale);
        ico_.setIsKYCAndAudit(kyc,audit);
    }
    // function getIcoCount(address _user) public virtual view returns(uint256){
    //     return _userIcoCount[_user];
    // }

    // function getUsersAllICO(address _user) public virtual view returns (ICOBase[] memory icobase){
    //     // ICOBase[] memory _usersIcos = new ICOBase[](_userIcoCount[_user]);
    //     // for(uint256 i = 0 ; i < _userIcoCount[_user];i++){
    //     //     _usersIcos[i] = icoList[_userIcoData[_user][i]];
    //     // }
    //     // return _usersIcos;
    // }

    function _makeICOObject(uint256 _lastIndex,DataParam calldata newICOData) internal view returns (ICOparam memory){
        ICOparam memory x = ICOparam(
            _lastIndex,
            true, // IsLive true by default
            msg.sender,
            address(this),
            newICOData,
            Fees(
            feesBNBPercent,
            ICOAdminWalletFees,
            ICOStakingPoolFees,
            stakingPoolAddress,
            adminWalletAddress
        )
        );
        return x;
    }
    function _totalFees(uint256 _liquiditySupply, uint256 _exchangeListingRateBNB, uint256 _hardCap, uint256 _presaleSupply) internal virtual returns(uint256){
        uint256 extraTokenForLiquidity =  _liquiditySupply * _hardCap / 10000  * _exchangeListingRateBNB;
        uint256 extraTokenForAdminFees = _presaleSupply.mul(ICOStakingPoolFees).div(10000);
        uint256 totalFees = _presaleSupply.mul(ICOAdminWalletFees).div(10000);
        return (_presaleSupply + extraTokenForLiquidity + extraTokenForAdminFees + totalFees);
    }

    // // View Functions
    // function getEndedICOs() public virtual view returns(ICOBase[] memory){
    //     return endedIcos;
    // }

    function getAllOngoingICOs() public virtual view returns(ICOBase[] memory){
        return ongoingIcos;
    }
    function getAICO(uint256 id)public virtual view returns(ICOBase memory){
        return icoList[id];
    }
    function updateAsSaleEnded() public virtual{
        // ongoingIcos[]
    }

    function setupFees(
    uint256 _adminWalletFee,
    uint256 _stakingPoolFee,
    uint256 _burnFee,
    uint256 _ICOAdminWalletFees,
    uint256 _ICOStakingPoolFees
    ) public virtual{
        owners();
        adminWalletFee = _adminWalletFee;
        stakingPoolFee = _stakingPoolFee;
        burnFee = _burnFee;
        ICOAdminWalletFees = _ICOAdminWalletFees;
        ICOStakingPoolFees = _ICOStakingPoolFees;
    }
}
