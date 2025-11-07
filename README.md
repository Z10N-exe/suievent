# Sui Move On‑Chain Event Ticketing

Smart contracts only (no frontend yet). Provides:
- Shared `Event` object with admin, supply cap, price.
- `buy_ticket` returns a `Ticket` NFT to the caller.
- `check_in` marks a ticket as used by an authorized address.

## Build

Prereqs: Sui CLI installed and configured.

```powershell
sui move build
```

## Publish

Publish from this folder (adjust `--gas-budget` as needed):

```powershell
sui client publish --path . --gas-budget 100000000
```

Take note of the returned `packageId`.

## Create an Event

Arguments:
- `admin`: address to receive payments and manage the event.
- `name`: string, event display name.
- `max_supply`: total ticket cap (u64).
- `price`: per ticket price in MIST (u64).

Example:

```powershell
sui client call \
  --package <PACKAGE_ID> \
  --module event_ticketing \
  --function create_event \
  --args <YOUR_ADDRESS> "My SuiConf" 1000 10000000 \
  --gas-budget 80000000
```

This creates and shares the `Event` object. Record the created `objectId` for later calls.

## Buy a Ticket

`buy_ticket` requires exact payment in a `Coin<SUI>` equal to `price`.
It returns the `Ticket` object to the transaction for composable routing.

You can compose a PTB to split a coin to exact `price` and route the result:

```powershell
# Example PTB via JSON (conceptual)/CLI composition steps:
# 1) Split a coin to exact price
# 2) Call buy_ticket with the exact coin
# 3) Receive the returned Ticket and optionally transfer to your address

sui client call \
  --package <PACKAGE_ID> \
  --module event_ticketing \
  --function buy_ticket \
  --args <EVENT_OBJECT_ID> <COIN_OBJECT_ID_EXACT_PRICE> \
  --gas-budget 80000000
```

Notes:
- If your coin amount is larger than `price`, split it first in the PTB; the function enforces exact payment.
- The payment is forwarded to the event admin.
- The returned `Ticket` can be transferred to your address in the same PTB.

## Check‑In

Only the `checkin_authority` may mark tickets as used.

```powershell
sui client call \
  --package <PACKAGE_ID> \
  --module event_ticketing \
  --function check_in \
  --args <EVENT_OBJECT_ID> <TICKET_OBJECT_ID> \
  --gas-budget 50000000
```

## Change Check‑In Authority

Admin‑only:

```powershell
sui client call \
  --package <PACKAGE_ID> \
  --module event_ticketing \
  --function set_checkin_authority \
  --args <EVENT_OBJECT_ID> <NEW_AUTH_ADDRESS> \
  --gas-budget 50000000
```

## Module Overview

- `Event`: shared object storing admin, name, `max_supply`, `sold`, `price` (MIST), and `checkin_authority`.
- `Ticket`: owned object storing `event_id`, sequential `serial`, and `used` flag.
- Functions:
  - `create_event(admin, name, max_supply, price, ctx)`
  - `buy_ticket(event, payment, ctx): Ticket`
  - `check_in(event, ticket, ctx)`
  - `set_checkin_authority(event, new_authority, ctx)`
  - `stats(event): (max_supply, sold, price)`

## Next Steps

- Add multiple ticket tiers and dynamic pricing.
- Implement optional refund/cancel policy.
- Emit event logs for off‑chain indexing.
- Integrate with a frontend.

