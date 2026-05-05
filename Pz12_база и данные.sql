DROP TABLE IF EXISTS operation_logs CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    user_id INT,
    balance INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE transactions (
    transactions_id SERIAL PRIMARY KEY,
    from_account_id INT,
    to_account_id INT,
    amount INT,
    created_at DATE,
    FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES accounts(account_id)
);

CREATE TABLE operation_logs (
    operation_logs_id SERIAL PRIMARY KEY,
    transactions_id INT,
    message VARCHAR(100) NOT NULL,
    created_at DATE,
    FOREIGN KEY (transactions_id) REFERENCES transactions(transactions_id)
);

INSERT INTO users (user_id, user_name) VALUES
(1, 'Аня'),
(2, 'Вася'),
(3, 'Семен');


INSERT INTO accounts (account_id, user_id, balance) VALUES
(1, 1, 5000),
(2, 2, 3000),
(3, 3, 1000);
