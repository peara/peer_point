pragma solidity ^0.4.20;
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens, bytes32 message) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens, bytes32 message);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// Unipos
// ----------------------------------------------------------------------------
contract PeerPoint is ERC20Interface {
    using SafeMath for uint;

    // Balances for each account
    mapping(address => uint256) balances;

    // Spendable points for each account
    mapping(address => uint256) points;

    // Next redeemable time for each account
    mapping(address => uint256) next_redeemable_times;

    // Amount of redeemable token each time
    uint256 redeemable_amount;

    // Contract owner
    address owner;

    string public symbol;
    string public  name;

    function PeerPoint() public {
        symbol = "PBP";
        name = "Peer Bonus Point";
        redeemable_amount = 400;
        owner = msg.sender;
    }

    // ------------------------------------------------------------------------
    // Total supply - just to fulfill erc20 interface
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return 1;
    }

    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    modifier updatePoints {
        // have not been updated recently
        if (now >= next_redeemable_times[msg.sender]) {
            redeem();
        }
        _;
    }

    // Get the spendable point for account `tokenOwner`
    function pointOf(address tokenOwner) public constant returns (uint point) {
        return points[tokenOwner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address to, uint tokens, bytes32 message) public updatePoints returns (bool success) {
        points[msg.sender] = points[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens, message);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public updatePoints returns (bool success) {
        return false;
    }

    function approve(address spender, uint tokens) public updatePoints returns (bool success) {
        return false;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return 0;
    }

    // Allow an address to redeem token if
    function redeem() public returns (uint point, uint next_redeemable_time) {
        address tokenOwner = msg.sender;
        // If block timestamp is larger than next redeemable time
        if (now >= next_redeemable_times[tokenOwner] ) {
            points[tokenOwner] = redeemable_amount;
            // next redeemable time is beginning of next day
            next_redeemable_times[tokenOwner] = now.sub(now % (1 days)).add(1 days);
        }

        return (points[tokenOwner], next_redeemable_times[tokenOwner]);
    }

    // Reset next redeemable time of an address, only callable by contract's owner
    function resetTime(address tokenOwner) public {
        require(msg.sender == owner);
        next_redeemable_times[tokenOwner] = 0;
    }
}
