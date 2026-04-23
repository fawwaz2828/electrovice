"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onChatMessageCreated = exports.onBookingStatusChanged = exports.onBookingCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const v2_1 = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
// ─────────────────────────────────────────────────────────────────
//  Trigger: booking baru dibuat (status: pending)
//  → kirim notif ke teknisi bahwa ada order masuk
// ─────────────────────────────────────────────────────────────────
exports.onBookingCreated = (0, firestore_1.onDocumentCreated)("bookings/{bookingId}", async (event) => {
    var _a, _b, _c, _d;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    // Hanya proses jika status awal adalah 'pending'
    if (data.status !== "pending")
        return;
    const bookingId = event.params.bookingId;
    const technicianId = (_b = data.technicianId) !== null && _b !== void 0 ? _b : "";
    const userName = (_c = data.userName) !== null && _c !== void 0 ? _c : "Customer";
    const category = (_d = data.category) !== null && _d !== void 0 ? _d : "";
    await _sendNotif(technicianId, {
        title: "New Order!",
        body: `${userName} needs help with ${category} repair.`,
        type: "new_order",
        bookingId,
    });
});
// ─────────────────────────────────────────────────────────────────
//  Trigger: booking status berubah
//  → tulis in-app notification ke Firestore
//  → kirim FCM push notification ke device (jika token tersedia)
// ─────────────────────────────────────────────────────────────────
exports.onBookingStatusChanged = (0, firestore_1.onDocumentUpdated)("bookings/{bookingId}", async (event) => {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    const before = (_a = event.data) === null || _a === void 0 ? void 0 : _a.before.data();
    const after = (_b = event.data) === null || _b === void 0 ? void 0 : _b.after.data();
    if (!before || !after)
        return;
    // Tidak ada perubahan status — skip
    if (before.status === after.status)
        return;
    const bookingId = event.params.bookingId;
    const userId = (_c = after.userId) !== null && _c !== void 0 ? _c : "";
    const technicianId = (_d = after.technicianId) !== null && _d !== void 0 ? _d : "";
    const technicianName = (_e = after.technicianName) !== null && _e !== void 0 ? _e : "Technician";
    const userName = (_f = after.userName) !== null && _f !== void 0 ? _f : "Customer";
    const cancelledBy = (_g = after.cancelledBy) !== null && _g !== void 0 ? _g : "";
    switch (after.status) {
        case "pending":
            await _sendNotif(technicianId, {
                title: "New Order!",
                body: `${userName} needs help with ${(_h = after.category) !== null && _h !== void 0 ? _h : ""} repair.`,
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
            }
            else {
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
});
// ─────────────────────────────────────────────────────────────────
//  Trigger: pesan chat baru masuk
//  → kirim FCM push ke pihak lain (bukan sender)
//  → tidak tulis in-app notif (chat sudah realtime di ChatPage)
// ─────────────────────────────────────────────────────────────────
exports.onChatMessageCreated = (0, firestore_1.onDocumentCreated)("chats/{chatId}/messages/{messageId}", async (event) => {
    var _a, _b, _c, _d, _e, _f, _g;
    const message = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!message)
        return;
    const chatId = event.params.chatId;
    const senderId = (_b = message.senderId) !== null && _b !== void 0 ? _b : "";
    const senderName = (_c = message.senderName) !== null && _c !== void 0 ? _c : "Someone";
    const text = (_d = message.text) !== null && _d !== void 0 ? _d : "";
    const imageUrl = (_e = message.imageUrl) !== null && _e !== void 0 ? _e : "";
    if (!senderId)
        return;
    // Ambil data chat room untuk tahu siapa penerima
    const chatSnap = await db.collection("chats").doc(chatId).get();
    const chatData = chatSnap.data();
    if (!chatData)
        return;
    const participants = (_f = chatData.participants) !== null && _f !== void 0 ? _f : [];
    const recipientId = participants.find((id) => id !== senderId);
    if (!recipientId)
        return;
    // Ambil FCM token penerima
    const userSnap = await db.collection("users").doc(recipientId).get();
    const fcmToken = (_g = userSnap.data()) === null || _g === void 0 ? void 0 : _g.fcmToken;
    if (!fcmToken)
        return;
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
    }
    catch (e) {
        v2_1.logger.warn("FCM chat send failed", { recipientId, error: e });
    }
});
// ─────────────────────────────────────────────────────────────────
//  Helper: tulis notif ke Firestore + kirim FCM push
// ─────────────────────────────────────────────────────────────────
async function _sendNotif(userId, payload) {
    var _a;
    if (!userId)
        return;
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
        const fcmToken = (_a = userSnap.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
        if (!fcmToken)
            return;
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
    }
    catch (e) {
        v2_1.logger.warn("FCM send failed", { userId, error: e });
    }
}
//# sourceMappingURL=index.js.map