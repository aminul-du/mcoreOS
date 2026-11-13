-- Idempotent monthly partitioning for radacct
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_partitioned_table pt
        JOIN pg_class c ON pt.partrelid = c.oid
        WHERE c.relname = 'radacct'
    ) THEN
        IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'radacct') THEN
            ALTER TABLE radacct RENAME TO radacct_legacy;
        END IF;

        CREATE TABLE radacct (
            radacctid BIGSERIAL,
            tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
            acctsessionid VARCHAR(64) NOT NULL DEFAULT '',
            acctuniqueid VARCHAR(32) NOT NULL,
            username VARCHAR(64) NOT NULL DEFAULT '',
            nasipaddress INET NOT NULL,
            acctstarttime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            acctupdatetime TIMESTAMPTZ,
            acctstoptime TIMESTAMPTZ,
            acctsessiontime BIGINT,
            acctinputoctets BIGINT,
            acctoutputoctets BIGINT,
            acctterminatecause VARCHAR(32),
            framedipaddress INET,
            PRIMARY KEY (radacctid, acctstarttime)
        ) PARTITION BY RANGE (acctstarttime);

        CREATE TABLE IF NOT EXISTS radacct_2026_11 PARTITION OF radacct
            FOR VALUES FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00');
        CREATE TABLE IF NOT EXISTS radacct_2026_12 PARTITION OF radacct
            FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');
        CREATE TABLE IF NOT EXISTS radacct_default PARTITION OF radacct DEFAULT;

        CREATE INDEX IF NOT EXISTS radacct_active_idx ON radacct (username) WHERE acctstoptime IS NULL;
        CREATE INDEX IF NOT EXISTS radacct_unique_session_idx ON radacct (acctuniqueid, acctstarttime);

        IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'radacct_legacy') THEN
            INSERT INTO radacct (
                tenant_id, acctsessionid, acctuniqueid, username, nasipaddress,
                acctstarttime, acctupdatetime, acctstoptime, acctsessiontime,
                acctinputoctets, acctoutputoctets, acctterminatecause, framedipaddress
            )
            SELECT
                tenant_id, acctsessionid, acctuniqueid, username, nasipaddress,
                COALESCE(acctstarttime, NOW()), acctupdatetime, acctstoptime, acctsessiontime,
                acctinputoctets, acctoutputoctets, acctterminatecause, framedipaddress
            FROM radacct_legacy;

            DROP TABLE radacct_legacy;
        END IF;

        ALTER TABLE radacct ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;
