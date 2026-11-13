CREATE TABLE IF NOT EXISTS nas (
    id SERIAL PRIMARY KEY,
    nasname VARCHAR(128) NOT NULL,
    shortname VARCHAR(32),
    type VARCHAR(30) DEFAULT 'mikrotik',
    ports INTEGER,
    secret VARCHAR(60) NOT NULL,
    server VARCHAR(64),
    community VARCHAR(50),
    description VARCHAR(200) DEFAULT 'SmartNet FD-02 NAS'
);

CREATE TABLE IF NOT EXISTS radcheck (
    id SERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
    username VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op CHAR(2) NOT NULL DEFAULT '==',
    value VARCHAR(253) NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radcheck_username_idx ON radcheck (username);

CREATE TABLE IF NOT EXISTS radreply (
    id SERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
    username VARCHAR(64) NOT NULL DEFAULT '',
    attribute VARCHAR(64) NOT NULL DEFAULT '',
    op CHAR(2) NOT NULL DEFAULT '=',
    value VARCHAR(253) NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radreply_username_idx ON radreply (username);

CREATE TABLE IF NOT EXISTS radacct (
    radacctid BIGSERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
    acctsessionid VARCHAR(64) NOT NULL DEFAULT '',
    acctuniqueid VARCHAR(32) NOT NULL UNIQUE,
    username VARCHAR(64) NOT NULL DEFAULT '',
    nasipaddress INET NOT NULL,
    acctstarttime TIMESTAMPTZ,
    acctupdatetime TIMESTAMPTZ,
    acctstoptime TIMESTAMPTZ,
    acctsessiontime BIGINT,
    acctinputoctets BIGINT,
    acctoutputoctets BIGINT,
    acctterminatecause VARCHAR(32),
    framedipaddress INET
);
CREATE INDEX IF NOT EXISTS radacct_active_idx ON radacct (username) WHERE acctstoptime IS NULL;
