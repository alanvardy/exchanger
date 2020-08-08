DROP TABLE IF EXISTS balances;


DROP TABLE IF EXISTS transactions;


DROP FUNCTION IF EXISTS aggregate_function;


CREATE TABLE balances (wallet_id INT, balance INT, CONSTRAINT unique_wallet_id UNIQUE (wallet_id));


CREATE TABLE transactions (wallet_id INT, amount INT);


CREATE FUNCTION aggregate_function() RETURNS TRIGGER AS $$
BEGIN
INSERT INTO balances (wallet_id, balance)
VALUES (NEW.wallet_id, NEW.amount)
ON CONFLICT (wallet_id) DO UPDATE SET balance = balances.balance + NEW.amount;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER aggregate_trigger AFTER
INSERT on transactions
FOR EACH ROW EXECUTE PROCEDURE aggregate_function();


INSERT INTO transactions (wallet_id, amount)
VALUES (32,
        3000);


INSERT INTO transactions (wallet_id, amount)
VALUES (32,
        6400);


SELECT *
FROM balances;

