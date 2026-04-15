"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onBookingStatusChanged = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const v2_1 = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
// ─────────────────────────────────────────────────────────────────
//  Trigger: booking status berubah
//  → tulis in-app notification ke Firestore
//  → kirim FCM push notification ke device (jika token tersedia)
// ─────────────────────────────────────────────────────────────────
exports.onBookingStatusChanged = (0, firestore_1.onDocumentUpdated)("bookings/{bookingId}", async (event) => {
    var _a, _b, _c, _d, _e, _f, _g;
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
    const technicianName = (_e = after.technicianName) !== null && _e !== void 0 ? _e : "Teknisi";
    const userName = (_f = after.userName) !== null && _f !== void 0 ? _f : "Customer";
    switch (after.status) {
        case "pending":
            await _sendNotif(technicianId, {
                title: "Pesanan Masuk!",
                body: `${userName} membutuhkan bantuan servis ${(_g = after.category) !== null && _g !== void 0 ? _g : ""}.`,
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