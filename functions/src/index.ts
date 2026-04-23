import { onDocumentUpdated, onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────
//  Trigger: booking baru dibuat (status: pending)
//  → kirim notif ke teknisi bahwa ada order masuk
// ─────────────────────────────────────────────────────────────────
export const onBookingCreated = onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    // Hanya proses jika status awal adalah 'pending'
    if (data.status !== "pending") return;

    const bookingId = event.params.bookingId;
    const technicianId: string = data.technicianId ?? "";
    const userName: string = data.userName ?? "Customer";
    const category: string = data.category ?? "";

    await _sendNotif(technicianId, {
      title: "New Order!",
      body: `${userName} needs help with ${category} repair.`,
      type: "new_order",
      bookingId,
    });
  }
);

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
    const technicianName: string = after.technicianName ?? "Technician";
    const userName: string = after.userName ?? "Customer";
    const cancelledBy: string = after.cancelledBy ?? "";

    switch (after.status as string) {
      case "pending":
        await _sendNotif(technicianId, {
          title: "New Order!",
          body: `${userName} needs help with ${after.category ?? ""} repair.`,
          type: "new_order",
          bookingId,
        });
        break;

      case "confirmed":
        await _sendNotif(userId, {
          title: "Order Accepted!",
          body: `${technicianName} is on the way to your location.`,
          type: "order_accepted",
          bookingId,
        });
        break;

      case "cancelled":
        if (cancelledBy === "technician") {
          await _sendNotif(userId, {
            title: "Order Declined",
            body: `${technicianName} is unable to accept your order at this time.`,
            type: "order_declined",
            bookingId,
          });
        } else {
          await _sendNotif(userId, {
            title: "Order Cancelled",
            body: "Your service order has been cancelled.",
            type: "order_cancelled",
            bookingId,
          });
          await _sendNotif(technicianId, {
            title: "Order Cancelled",
            body: `${userName} has cancelled the service order.`,
            type: "order_cancelled",
            bookingId,
          });
        }
        break;

      case "on_progress":
        await _sendNotif(userId, {
          title: "Technician Has Arrived!",
          body: `${technicianName} has started working on your device.`,
          type: "on_progress",
          bookingId,
        });
        break;

      case "awaiting_payment":
        await _sendNotif(userId, {
          title: "Invoice Ready",
          body: "Repair completed. Please confirm your payment.",
          type: "awaiting_payment",
          bookingId,
        });
        break;

      case "done":
        await _sendNotif(technicianId, {
          title: "Payment Received",
          body: `${userName} has confirmed the payment. Job complete!`,
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
//  Trigger: pesan chat baru masuk
//  → kirim FCM push ke pihak lain (bukan sender)
//  → tidak tulis in-app notif (chat sudah realtime di ChatPage)
// ─────────────────────────────────────────────────────────────────
export const onChatMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const chatId = event.params.chatId;
    const senderId: string = message.senderId ?? "";
    const senderName: string = message.senderName ?? "Someone";
    const text: string = message.text ?? "";
    const imageUrl: string = message.imageUrl ?? "";

    if (!senderId) return;

    // Ambil data chat room untuk tahu siapa penerima
    const chatSnap = await db.collection("chats").doc(chatId).get();
    const chatData = chatSnap.data();
    if (!chatData) return;

    const participants: string[] = chatData.participants ?? [];
    const recipientId = participants.find((id: string) => id !== senderId);
    if (!recipientId) return;

    // Ambil FCM token penerima
    const userSnap = await db.collection("users").doc(recipientId).get();
    const fcmToken: string | undefined = userSnap.data()?.fcmToken;
    if (!fcmToken) return;

    // Susun preview pesan
    const body = imageUrl ? "📷 sent a photo" : (text.length > 80 ? text.substring(0, 80) + "…" : text);

    try {
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: senderName,
          body,
        },
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
          type: "chat",
          chatId,
          senderId,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    } catch (e) {
      logger.warn("FCM chat send failed", { recipientId, error: e });
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
