CREATE OR REPLACE PROCEDURE READ_REVIEW_BYPRODUCT(L_PRODUCT_ID IN INTEGER)
AS
    L_CURSOR SYS_REFCURSOR;
BEGIN
    OPEN L_CURSOR FOR
        SELECT *
        FROM REVIEW
        WHERE PRODUCT_ID = L_PRODUCT_ID;

    DBMS_SQL.RETURN_RESULT(L_CURSOR);
END;
/

CREATE OR REPLACE PROCEDURE READ_REVIEW_BYCUSTOMER(L_CUSTOMER_ID IN INTEGER)
AS
    L_CURSOR SYS_REFCURSOR;
BEGIN
    OPEN L_CURSOR FOR
        SELECT *
        FROM REVIEW
        WHERE CUSTOMER_ID = L_CUSTOMER_ID;

    DBMS_SQL.RETURN_RESULT(L_CURSOR);
END;
/

CREATE OR REPLACE PROCEDURE READ_REVIEW_BYPRODUCT(L_PRODUCT_ID IN INTEGER)
AS
    L_CURSOR SYS_REFCURSOR;
BEGIN
    OPEN L_CURSOR FOR
        SELECT *
        FROM REVIEW
        WHERE PRODUCT_ID = L_PRODUCT_ID;

    DBMS_SQL.RETURN_RESULT(L_CURSOR);
END;
/






CREATE OR REPLACE FUNCTION HAS_REVIEW_ON_PRODUCT(
    L_CUSTOMER_ID INTEGER,
    L_PRODUCT_ID INTEGER
)
RETURN INTEGER
IS
    L_ID INTEGER := 0;
BEGIN
    SELECT ID
    INTO L_ID
    FROM REVIEW
    WHERE CUSTOMER_ID = L_CUSTOMER_ID AND PRODUCT_ID = L_PRODUCT_ID;
    
    RETURN 1;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION HAS_BUY_PRODUCT(
    L_CUSTOMER_ID INTEGER,
    L_PRODUCT_ID INTEGER
)
RETURN INTEGER
IS
    L_ID INTEGER := 0;
BEGIN
    SELECT ID INTO L_ID
    FROM ORDERS
    WHERE CUSTOMER_ID = L_CUSTOMER_ID
    FETCH FIRST 1 ROWS ONLY;
    
    FOR ITEM IN (SELECT * FROM ORDERS WHERE CUSTOMER_ID = L_CUSTOMER_ID) LOOP
        SELECT ORDERS_ID INTO L_ID
        FROM ORDERS_ITEM
        WHERE ORDERS_ID = ITEM.ID AND PRODUCT_ID = L_PRODUCT_ID;
    END LOOP;
    
    RETURN 1;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION CREATE_REVIEW(
    L_RATING IN INTEGER,
    L_NOTE IN STRING,
    L_CUSTOMER_ID IN INTEGER,
    L_PRODUCT_ID IN INTEGER
) RETURN INTEGER
IS
    L_HAS_REVIEW INTEGER := -1;
    L_HAS_BUY INTEGER := -1;
BEGIN
    L_HAS_REVIEW := HAS_REVIEW_ON_PRODUCT(L_CUSTOMER_ID, L_PRODUCT_ID);
    IF L_HAS_REVIEW = 0 THEN
        L_HAS_BUY := HAS_BUY_PRODUCT(L_CUSTOMER_ID, L_PRODUCT_ID);
        IF L_HAS_BUY = 1 THEN
            INSERT INTO REVIEW(ID, RATING, NOTE, PRODUCT_ID, CUSTOMER_ID)
            VALUES(null, L_RATING, L_NOTE, L_PRODUCT_ID, L_CUSTOMER_ID);
            RETURN 1;
        END IF;
    END IF;
    
    RETURN 0;
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RETURN 0;
END;
/