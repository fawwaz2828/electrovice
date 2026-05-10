import { Router } from "express";
import { handleMidtransWebhook } from "./midtrans.controller";

export function createMidtransRouter(serverKey: string): Router {
  const router = Router();

  router.post("/webhook", (req, res) => {
    handleMidtransWebhook(req, res, serverKey);
  });

  return router;
}
