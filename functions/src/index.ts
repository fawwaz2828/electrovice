import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────
//  Trigger: booking status berubah
//  → tulis in-app notification ke Firestore
//  → kirim FCM push notification ke device (jika token tersedia)
// ─────────────────────────────────────────────────────────────────
export const onBookingStatusChanged = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    // Tidak ada perubahan status — skip
    if (before.status === after.status) return;

    const bookingId = event.params.bookingId;
    const userId: string = after.userId ?? "";
    const technicianId: string = after.technicianId ?? "";
    const technicianName: string = after.technicianName ?? "Teknisi";
    const userName: string = after.userName ?? "Customer";

    switch (after.status as string) {
      case "pending":
        await _sendNotif(technicianId, {
          title: "Pesanan Masuk!",
          body: `${userName} membutuhkan bantuan servis ${after.category ?? ""}.`,
          type: "new_order",
          bookingId,
        });
        break;

      case "confirmed":
        await _sendNotif(userId, {
          title: "Pesanan Diterima!",
          body: `${technicianName} sedang dalam perjalanan ke lokasi kamu.`,
          type: "order_accepted",
          bookingId,
        });
        break;

      case "cancelled":
        // Kirim ke kedua pihak karena tidak bisa tahu siapa yang cancel dari server
        await _sendNotif(userId, {
          title: "Pesanan Dibatalkan",
          body: "Pesanan servis telah dibatalkan.",
          type: "order_cancelled",
          bookingId,
        });
        await _sendNotif(technicianId, {
          title: "Pesanan Dibatalkan",
          body: "Pesanan servis telah dibatalkan.",
          type: "order_cancelled",
          bookingId,
        });
        break;

      case "on_progress":
        await _sendNotif(userId, {
          title: "Teknisi Sudah Tiba!",
          body: `${technicianName} mulai mengerjakan perangkat kamu.`,
          type: "on_progress",
          bookingId,
        });
        break;

      case "awaiting_payment":
        await _sendNotif(userId, {
          title: "Tagihan Siap Dibayar",
          body: "Perbaikan selesai. Silakan konfirmasi pembayaran.",
          type: "awaiting_payment",
          bookingId,
        });
        break;

      case "done":
        await _sendNotif(technicianId, {
          title: "Pembayaran Diterima",
          body: `${userName} telah mengkonfirmasi pembayaran. Pekerjaan selesai!`,
          type: "payment_confirmed",
          bookingId,
        });
        break;

      default:
        return;
    }
  }
);

// ─────────────────────────────────────────────────────────────────
//  Helper: tulis notif ke Firestore + kirim FCM push
// ─────────────────────────────────────────────────────────────────
async function _sendNotif(
  userId: string,
  payload: {
    title: string;
    body: string;
    type: string;
    bookingId: string;
  }
): Promise<void> {
  if (!userId) return;

  const { title, body, type, bookingId } = payload;

  // 1. In-app notification (Firestore) — dibaca Flutter secara realtime
  await db
    .collection("notifications")
    .doc(userId)
    .collection("items")
    .add({
      title,
      body,
      type,
      bookingId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  // 2. FCM push — butuh fcmToken tersimpan di users/{userId}
  try {
    const userSnap = await db.collection("users").doc(userId).get();
    const fcmToken: string | undefined = userSnap.data()?.fcmToken;
    if (!fcmToken) return;

    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      android: {
        notification: {
          channelId: "electrovice_notifications",
          priority: "high",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: { sound: "default", badge: 1 },
        },
      },
      data: {
        bookingId,
        type,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    });
  } catch (e) {
    logger.warn("FCM send failed", { userId, error: e });
  }
}
