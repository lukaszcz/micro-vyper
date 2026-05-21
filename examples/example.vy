#pragma version ^0.4.0
#pragma nonreentrancy on
#pragma optimize codesize

# TODO: add more test coverage

event Payment:
    amount: indexed(uint256)
    sender: address

struct Bid:
    bidder: address
    amount: uint256

flag Status: ACTIVE PENDING CLOSED

owner: public(address)
best_bid: public(Bid)
total_paid: public(uint256)
MAX_SUPPLY: constant(uint256) = 1000

interface IOracle:
    def get_price() -> uint256: view
    def notify(): nonpayable

@deploy
def __init__():
    self.owner = msg.sender

@external
@payable
def bid():
    assert msg.value > self.best_bid.amount, "bid too low"
    self.best_bid = Bid(bidder=msg.sender, amount=msg.value)
    self.total_paid += msg.value
    log Payment(msg.value, msg.sender)

@external
@view
def quote_fee(value: uint256) -> uint256:
    return max(value // 100, as_wei_value(1, "wei"))

@external
@raw_return
def proxy(target: address, data: Bytes[4096]) -> Bytes[4096]:
    response: Bytes[4096] = raw_call(target, data, max_outsize=4096)
    return response

@internal
def _fail():
    raise UNREACHABLE

# Abstract method example
@abstract
def _before_action():
    ...

@override(base_module)
def _before_action():
    pass

# Boolean and None
flag_set: bool = True or False and not None

# Numeric literals
hex_val: uint256 = 0xFF
bin_val: uint8 = 0b1010
oct_val: uint8 = 0o77
dec_val: decimal = 3.14e1

# Hex string
sig: bytes32 = method_id("transfer(address,uint256)")

# Bytes types
small_bytes: bytes32 = empty(bytes32)
dyn_data: DynArray[uint256, 10] = []

# EVM operations
result: uint256 = staticcall IOracle(0x0).get_price()
extcall IOracle(0x0).notify()

# Module composition keywords
# implements: IOracle
# exports: some_func
# initializes: some_module
# uses: some_module
