CREATE OR REPLACE PROCEDURE transfer_money(
    p_from_account_id INT,
    p_to_account_id INT,
    p_amount INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_balance INT;
    v_transaction_id INT;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Сумма должна быть > 0';
    END IF;
    
    IF p_from_account_id = p_to_account_id THEN
        RAISE EXCEPTION 'Нельзя перевести самому себе';
    END IF;


    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_from_account_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Счёт отправителя % не найден', p_from_account_id;
    END IF;
    
    PERFORM 1 FROM accounts
    WHERE account_id = p_to_account_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Счёт получателя % не найден', p_to_account_id;
    END IF;
    
    IF v_balance < p_amount THEN
        RAISE EXCEPTION 'Недостаточно средств. Доступно: %', v_balance;
    END IF;
    
    UPDATE accounts SET balance = balance - p_amount
    WHERE account_id = p_from_account_id;
    UPDATE accounts SET balance = balance + p_amount
    WHERE account_id = p_to_account_id;
    
    INSERT INTO transactions (from_account_id, to_account_id, amount, created_at)
    VALUES (p_from_account_id, p_to_account_id, p_amount, CURRENT_DATE)
    RETURNING transactions_id INTO v_transaction_id;
    
    INSERT INTO operation_logs (message, created_at, transactions_id)
    VALUES ('Перевод выполнен', CURRENT_DATE, v_transaction_id);
    
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO operation_logs (message, created_at, transactions_id)
        VALUES (SQLERRM, CURRENT_DATE, NULL);
        ROLLBACK;
        RAISE;
END;
$$;