module event_ticket::event_ticket {
    use sui::event;
    use std::ascii;

    public struct TicketEvent has copy, drop {
        event_name: ascii::String,
        seat_number: u64,
        owner: address,
    }

    public fun emit_ticket_event(
        event_name: ascii::String,
        seat_number: u64,
        owner: address
    ) {
        event::emit(TicketEvent {
            event_name,
            seat_number,
            owner,
        });
    }
}