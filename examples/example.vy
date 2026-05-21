#pragma version ^0.4.0
#pragma nonreentrancy on
#pragma optimize codesize

event Payment:
    amount: indexed(uint256)
    sender: address

struct Bid:
    bidder: address
    amount: uint256

owner: public(address)
best_bid: public(Bid)
total_paid: public(uint256)

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
