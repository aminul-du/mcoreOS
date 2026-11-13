CREATE OR REPLACE FUNCTION fn_seed_test_voucher(p_user VARCHAR, p_pass VARCHAR, p_rate VARCHAR)
RETURNS VOID AS $$
BEGIN
    DELETE FROM radcheck WHERE username = p_user;
    DELETE FROM radreply WHERE username = p_user;
    INSERT INTO radcheck (username, attribute, op, value)
    VALUES (p_user, 'Cleartext-Password', ':=', p_pass);
    INSERT INTO radreply (username, attribute, op, value)
    VALUES (p_user, 'Mikrotik-Rate-Limit', '=', p_rate);
END;
$$ LANGUAGE plpgsql;
