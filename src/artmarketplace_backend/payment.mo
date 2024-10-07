import { canister_ts, Nat, Principal, Vec } from "motoko/stdlib";

// Define data structures
type PaymentId = Nat;
type Amount = Nat;

type Payment = {
    id: PaymentId;
    order_id: OrderId;
    amount: Amount;
    status: PaymentStatus;
};

// Define canister state
actor PaymentCanister {
    var payments: Vec<Payment>;

    public query get_payment(id: PaymentId) -> Option<Payment> {
        payments.find(payment => payment.id == id)
    }

    public update create_payment(order_id: OrderId, amount: Amount) -> PaymentId {
        let id = payments.len() as PaymentId + 1;
        let payment = Payment {
            id,
            order_id,
            amount,
            status: PaymentStatus.pending,
        };
        payments.push(payment);
        id
    }

    public update process_payment(id: PaymentId) -> Result<(), Text> {
        let index = payments.find_index(payment => payment.id == id);
        if let Some(index) = index {
            let payment = &mut payments[index];
            if payment.status == PaymentStatus.pending {
                // Process payment using ICP or other supported cryptocurrencies
                // ...
                payment.status = PaymentStatus.completed;
                Ok(())
            } else {
                Err("Payment already processed")
            }
        } else {
            Err("Payment not found")
        }
    }

    public update refund_payment(id: PaymentId) -> Result<(), Text> {
        let index = payments.find_index(payment => payment.id == id);
        if let Some(index) = index {
            let payment = &mut payments[index];
            if payment.status == PaymentStatus.completed {
                // Refund payment using ICP or other supported cryptocurrencies
                // ...
                payment.status = PaymentStatus.refunded;
                Ok(())
            } else {
                Err("Payment cannot be refunded")
            }
        } else {
            Err("Payment not found")
        }
    }
};