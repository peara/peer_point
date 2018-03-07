pragma solidity ^0.4.20;
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
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

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

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
    function transfer(address to, uint tokens) public updatePoints returns (bool success) {
        points[msg.sender] = points[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    // Send `tokens` amount of tokens from address `from` to address `to`
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address from, address to, uint tokens) public updatePoints returns (bool success) {
        points[from] = points[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }

    // Allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address spender, uint tokens) public updatePoints returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
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
