DROP TABLE IF EXISTS wallets;


DROP TABLE IF EXISTS transactions;


DROP FUNCTION IF EXISTS aggregate_function;


CREATE TABLE wallets (id INT, balance INT DEFAULT 0);


CREATE TABLE transactions (to_wallet_id INT, from_wallet_id INT, add INT, subtract INT);


CREATE FUNCTION aggregate_function() RETURNS TRIGGER AS $$
BEGIN

UPDATE wallets
SET balance = balance - NEW.subtract
WHERE id = NEW.from_wallet_id;

UPDATE wallets
SET balance = balance + NEW.add
WHERE id = NEW.to_wallet_id;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER aggregate_trigger AFTER
INSERT on transactions
FOR EACH ROW EXECUTE PROCEDURE aggregate_function();


INSERT INTO wallets (id)
VALUES (32);


INSERT INTO wallets (id)
VALUES (40);


INSERT INTO transactions (to_wallet_id, from_wallet_id, add, subtract)
VALUES (32,
        40,
        3000,
        3000);


SELECT *
FROM wallets;

