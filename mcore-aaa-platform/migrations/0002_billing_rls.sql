CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    slug VARCHAR(60) UNIQUE NOT NULL,
    currency VARCHAR(10) DEFAULT 'BDT',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO tenants (id, name, slug)
VALUES ('00000000-0000-0000-0000-000000000001', 'Default ISP Tenant', 'default')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    name VARCHAR(80) NOT NULL,
    rate_limit VARCHAR(64) NOT NULL,
    duration_minutes INTEGER NOT NULL,
    price_bdt NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    provider VARCHAR(32) NOT NULL, -- bkash, nagad, sslcommerz
    trx_id VARCHAR(100) UNIQUE,
    msisdn VARCHAR(20),
    amount_bdt NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    voucher_code VARCHAR(32),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE radcheck ENABLE ROW LEVEL SECURITY;
ALTER TABLE radreply ENABLE ROW LEVEL SECURITY;
ALTER TABLE radacct ENABLE ROW LEVEL SECURITY;
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_intents ENABLE ROW LEVEL SECURITY;
