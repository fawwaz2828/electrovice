import * as crypto from "crypto";
import { logger } from "firebase-functions/v2";
import * as admin from "firebase-admin";

export type TransactionStatus = "settlement" | "pending" | "expire" | "cancel";

export interface MidtransWebhookPayload {
  order_id: string;
  transaction_status: TransactionStatus;
  signature_key: string;
  gross_amount: string;
  status_code: string;
  payment_type?: string;
  transaction_id?: string;
}

/**
 * Verifikasi signature_key dari Midtrans.
 * Formula: SHA512(order_id + status_code + gross_amount + server_key)
 */
export function verifySignature(
  payload: MidtransWebhookPayload,
  serverKey: string
): boolean {
  const raw = `${payload.order_id}${payload.status_code}${payload.gross_amount}${serverKey}`;
  const expected = crypto.createHash("sha512").update(raw).digest("hex");
  return expected === payload.signature_key;
}

/**
 * Update status order di Firestore.
 * order_id diasumsikan sama dengan bookingId yang tersimpan di collection "bookings".
 */
export async function updateOrderStatus(
  orderId: string,
  status: TransactionStatus
): Promise<void> {
  const firestoreStatus = mapMidtransStatusToApp(status);

  const db = admin.firestore();
  await db.collection("bookings").doc(orderId).update({
    paymentStatus: firestoreStatus,
    paymentUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info("Order status updated", { orderId, firestoreStatus });
}

function mapMidtransStatusToApp(status: TransactionStatus): string {
  switch (status) {
    case "settlement": return "paid";
    case "pending":    return "pending";
    case "expire":     return "expired";
    case "cancel":     return "cancelled";
  }
}
