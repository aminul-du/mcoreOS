import os, secrets, string
import psycopg2
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="MCore AAA Billing API (FD-03)")

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "10.0.112.10"),
        dbname=os.getenv("DB_DATABASE", "mcore_aaa"),
        user=os.getenv("RADIUS_DB_USER", "radius"),
        password=os.getenv("RADIUS_DB_PASSWORD", "change_me_strong_db_pass"),
    )

class VoucherRequest(BaseModel):
    rate_limit: str = "10M/10M"
    prefix: str = "MC"

class PaymentWebhook(BaseModel):
    provider: str  # bkash | nagad | sslcommerz
    trx_id: str
    msisdn: str
    amount_bdt: float
    rate_limit: str = "10M/10M"

def gen_code(prefix: str = "MC") -> str:
    alphabet = string.ascii_uppercase + string.digits
    return f"{prefix}-" + "".join(secrets.choice(alphabet) for _ in range(6))

@app.get("/api/v1/health")
def health():
    return {"status": "ok", "domain": "FD-03", "ip": "10.0.32.10"}

@app.post("/api/v1/vouchers")
def create_voucher(req: VoucherRequest):
    code = gen_code(req.prefix)
    pin = "".join(secrets.choice(string.digits) for _ in range(4))
    with get_db() as conn, conn.cursor() as cur:
        cur.execute("SELECT fn_seed_test_voucher(%s, %s, %s);", (code, pin, req.rate_limit))
    return {"voucher_code": code, "pin": pin, "rate_limit": req.rate_limit}

@app.post("/webhooks/payment")
def payment_webhook(payload: PaymentWebhook):
    if payload.amount_bdt <= 0:
        raise HTTPException(status_code=400, detail="Invalid BDT amount")
    code = gen_code("PAY")
    pin = "".join(secrets.choice(string.digits) for _ in range(4))
    with get_db() as conn, conn.cursor() as cur:
        cur.execute("SELECT fn_seed_test_voucher(%s, %s, %s);", (code, pin, payload.rate_limit))
        cur.execute(
            """
            INSERT INTO payment_intents (provider, trx_id, msisdn, amount_bdt, status, voucher_code)
            VALUES (%s, %s, %s, %s, 'completed', %s)
            ON CONFLICT (trx_id) DO NOTHING;
            """,
            (payload.provider, payload.trx_id, payload.msisdn, payload.amount_bdt, code),
        )
    return {
        "status": "activated",
        "provider": payload.provider,
        "trx_id": payload.trx_id,
        "voucher_code": code,
        "pin": pin,
    }
