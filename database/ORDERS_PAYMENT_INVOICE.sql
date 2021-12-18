-- DATA MANIPULATION LANGUAGE
SET SERVEROUTPUT ON;
-- ORDERS
SELECT * FROM ORDERS;

SELECT * FROM ORDERS_ITEM;

-- INVOICE
SELECT * FROM INVOICE;

-- PAYMENT
SELECT * FROM PAYMENT;

INSERT INTO PAYMENT(ID, METHOD, ACC_NUMBER, status)
VALUES (NULL, 'GOPAY', '082317900923', 1);

CREATE OR REPLACE FUNCTION CREATE_PAYMENT(L_METHOD IN STRING, L_NUMBER IN STRING) RETURN INTEGER
AS
L_PAYMENT PAYMENT%ROWTYPE;
BEGIN
    SELECT * INTO L_PAYMENT
    FROM PAYMENT
    WHERE LOWER(METHOD) = LOWER(L_METHOD);
    
    RETURN 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO PAYMENT(ID, METHOD, ACC_NUMBER, STATUS)
            VALUES (NULL, L_METHOD, L_NUMBER, 1);
            RETURN 0;
END;

CREATE OR REPLACE FUNCTION UPDATE_PAYMENT(L_PAYMENT_ID IN INTEGER, L_METHOD IN STRING, L_NUMBER IN STRING, L_STATUS IN INTEGER) RETURN INTEGER
AS
L_PAYMENT PAYMENT%ROWTYPE;
BEGIN
    SELECT * INTO L_PAYMENT
    FROM PAYMENT
    WHERE LOWER(METHOD) = LOWER(L_METHOD) AND ID != L_PAYMENT_ID;
    
    RETURN 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            UPDATE PAYMENT SET
                METHOD = L_METHOD,
                ACC_NUMBER = L_NUMBER,
                STATUS = L_STATUS
            WHERE ID = L_PAYMENT_ID;
            RETURN 0;
END;




    

    


