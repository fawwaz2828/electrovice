import { Request, Response } from "express";
import { logger } from "firebase-functions/v2";
import {
  MidtransWebhookPayload,
  verifySignature,
  updateOrderStatus,
} from "./midtrans.service";

export async function handleMidtransWebhook(
  req: Request,
  res: Response,
  serverKey: string
): Promise<void> {
  const payload = req.body as MidtransWebhookPayload;
  const { order_id, transaction_status, gross_amount, status_code } = payload;

  logger.info("Midtrans webhook received", { order_id, transaction_status, status_code });

  // 1. Validasi field wajib
  if (!order_id || !transaction_status || !gross_amount || !status_code || !payload.signature_key) {
    logger.warn("Webhook rejected: missing required fields", { payload });
    res.status(400).json({ message: "Bad request: missing fields" });
    return;
  }

  // 2. Verifikasi signature untuk menolak request palsu
  if (!verifySignature(payload, serverKey)) {
    logger.warn("Webhook rejected: invalid signature", { order_id });
    res.status(403).json({ message: "Forbidden: invalid signature" });
    return;
  }

  // 3. Handle berdasarkan status transaksi
  try {
    switch (transaction_status) {
      case "settlement":
        logger.info("Payment settled", { order_id, gross_amount });
        await updateOrderStatus(order_id, "settlement");
        break;

      case "pending":
        logger.info("Payment pending", { order_id });
        await updateOrderStatus(order_id, "pending");
        break;

      case "expire":
        logger.info("Payment expired", { order_id });
        await updateOrderStatus(order_id, "expire");
        break;

      case "cancel":
        logger.info("Payment cancelled", { order_id });
        await updateOrderStatus(order_id, "cancel");
        break;

      default:
        logger.warn("Unhandled transaction_status", { transaction_status, order_id });
        break;
    }

    // 4. Selalu return 200 agar Midtrans tidak retry webhook
    res.status(200).json({ message: "OK" });
  } catch (error) {
    logger.error("Error handling webhook", { order_id, error });
    // Tetap return 200 — Midtrans akan retry jika response != 2xx
    res.status(200).json({ message: "OK" });
  }
}
