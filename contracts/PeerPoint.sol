pragma solidity ^0.4.23;


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint256 totalSupply_);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// Unipos
// ----------------------------------------------------------------------------
contract PeerPoint is ERC20Interface {
    using SafeMath for uint256;

    // Balances for each account
    mapping(address => uint256) balances;

    // Spendable points for each account
    mapping(address => uint256) points;

    // Next redeemable time for each account
    mapping(address => uint256) nextRedeemableTimes;

    // Amount of redeemable token each time
    uint256 redeemableAmount;

    // Contract owner
    address owner;

    string public symbol;
    string public name;

    event SentPoint(address indexed _from, address indexed _to, uint256 _value, bytes32 _message);

    constructor () public {
        symbol = "PBP";
        name = "Peer Bonus Point";
        redeemableAmount = 400;
        owner = msg.sender;
    }

    // ------------------------------------------------------------------------
    // Total supply - just to fulfill erc20 interface
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint256) {}

    // Get the token balance for account `_owner`
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    modifier updatePoints {
        // have not been updated recently
        if (now >= nextRedeemableTimes[msg.sender]) {
            redeem();
        }
        _;
    }

    // Get the spendable point for account `_owner`
    function pointOf(address _owner) public view returns (uint256) {
        if (now > nextRedeemableTimes[msg.sender]) {
            return redeemableAmount;
        }
        return points[_owner];
    }

    function sendPoint(address _to, uint256 _value, bytes32 _message)
        public
        updatePoints
        returns (bool success)
    {
        require(_to != address(0));
        require(_to != msg.sender);
        require(_value <= points[msg.sender]);
        if (now > nextRedeemableTimes[msg.sender]) {
            points[msg.sender] = redeemableAmount;
        }
        points[msg.sender] = points[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit SentPoint(msg.sender, _to, _value, _message);
        return true;
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _to;
        _value;
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        _from;
        _to;
        _value;
        return false;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _spender;
        _value;
        return false;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        _owner;
        _spender;
        return 0;
    }


    // Allow an address to redeem token if
    function redeem() public returns (uint256 point, uint256 nextRedeemableTime) {
        address _owner = msg.sender;
        // If block timestamp is larger than next redeemable time
        if (now >= nextRedeemableTimes[_owner] ) {
            points[_owner] = redeemableAmount;

            nextRedeemableTimes[_owner] = now.sub(now % (1 days)).add(1 days);
        }

        return (points[_owner], nextRedeemableTimes[_owner]);
    }

    // Reset next redeemable time of an address, only callable by contract's owner
    function resetTime(address _owner) public {
        require(msg.sender == owner);
        nextRedeemableTimes[_owner] = 0;
    }
}
