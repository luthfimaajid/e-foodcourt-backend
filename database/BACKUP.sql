-- DATA DEFINITION LANGUAGE
--Merchant
CREATE TABLE merchant (
    id       INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    name     VARCHAR2(255 CHAR),
    username VARCHAR2(255 CHAR),
    password VARCHAR2(255 CHAR)
);

ALTER TABLE merchant 
    ADD CONSTRAINT merchant_pk PRIMARY KEY ( id );

--category
CREATE TABLE category (
    id   INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    name VARCHAR2(255 CHAR)
);
 
ALTER TABLE category 
    ADD CONSTRAINT category_pk PRIMARY KEY ( id )
    ADD CONSTRAINT NAME UNIQUE(NAME);

--products
CREATE TABLE product (
    id          INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    description CLOB,
    title       VARCHAR2(255 CHAR) NOT NULL,
    price       INTEGER,
    stock       INTEGER,
    image_url   VARCHAR2(255 CHAR),
    merchant_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL
);

ALTER TABLE product 
    ADD CONSTRAINT product_pk PRIMARY KEY ( id )
    ADD CONSTRAINT product_merchant_fk FOREIGN KEY ( merchant_id )
        REFERENCES merchant ( id ) ON DELETE CASCADE
    ADD CONSTRAINT product_category_fk FOREIGN KEY ( category_id )
        REFERENCES category ( id );
        
--customers
CREATE TABLE customer (
    id       INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    email    VARCHAR2(255 CHAR),
    password VARCHAR2(255 CHAR),
    username VARCHAR2(255 CHAR),
    phone    VARCHAR2(15 CHAR)
);

ALTER TABLE customer 
    ADD CONSTRAINT customer_pk PRIMARY KEY ( id )
    ADD CONSTRAINT EMAIL UNIQUE(EMAIL)
    ADD CONSTRAINT USERNAME UNIQUE(USERNAME)
    ADD CONSTRAINT PHONE UNIQUE(PHONE);


--reviews
CREATE TABLE review (
    id           INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    rating       INTEGER NOT NULL,
    note         CLOB,
    product_id  INTEGER NOT NULL,
    customer_id INTEGER NOT NULL
);

ALTER TABLE review 
    ADD CONSTRAINT review_pk PRIMARY KEY ( id )
    ADD CONSTRAINT review_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id ) ON DELETE CASCADE
    ADD CONSTRAINT review_product_fk FOREIGN KEY ( product_id )
        REFERENCES product ( id ) ON DELETE CASCADE;
        

--carts
CREATE TABLE cart (
    id           INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    total_item  INTEGER,
    total_price INTEGER,
    customer_id INTEGER NOT NULL
);

CREATE UNIQUE INDEX cart__idx ON
    cart (
        customer_id
    ASC );

ALTER TABLE cart 
    ADD CONSTRAINT cart_pk PRIMARY KEY ( id )
    ADD CONSTRAINT cart_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id ) ON DELETE CASCADE;
        
--carts-items
CREATE TABLE cart_item (
    cart_id    INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity    INTEGER
);

ALTER TABLE cart_item 
    ADD CONSTRAINT cart_item_pk PRIMARY KEY ( cart_id, product_id )
    ADD CONSTRAINT cart_item_cart_fk FOREIGN KEY ( cart_id )
        REFERENCES cart ( id ) ON DELETE CASCADE
    ADD CONSTRAINT cart_item_product_fk FOREIGN KEY ( product_id )
        REFERENCES product ( id ) ON DELETE CASCADE;
        
        
--orders
CREATE TABLE orders (
    id          INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    status      CHAR(1),
    total_item  INTEGER,
    total_price INTEGER,
    customer_id INTEGER NOT NULL,
    merchant_id INTEGER NOT NULL,
    payment_id  INTEGER NOT NULL
);

ALTER TABLE orders 
    ADD CONSTRAINT orders_pk PRIMARY KEY ( id )
    ADD CONSTRAINT orders_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id )
    ADD CONSTRAINT orders_merchant_fk FOREIGN KEY ( merchant_id )
        REFERENCES merchant ( id )
    ADD CONSTRAINT orders_payment_fk FOREIGN KEY ( payment_id )
        REFERENCES payment ( id );

CREATE SEQUENCE ORDER_SEQ START WITH 1;
        
        
--orders-items
CREATE TABLE orders_item (
    orders_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity    INTEGER
);

ALTER TABLE orders_item 
    ADD CONSTRAINT orders_item_pk PRIMARY KEY ( product_id, orders_id )
    ADD CONSTRAINT orders_item_orders_fk FOREIGN KEY ( orders_id )
        REFERENCES orders ( id ) ON DELETE CASCADE
    ADD CONSTRAINT orders_item_product_fk FOREIGN KEY ( product_id )
        REFERENCES product ( id ) ON DELETE CASCADE;

-- payment method
CREATE TABLE payment (
    id         INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    method     VARCHAR2(255 CHAR),
    acc_number VARCHAR2(255 CHAR)
);

ALTER TABLE payment ADD CONSTRAINT payment_pk PRIMARY KEY ( id );

-- DATA MANIPULATION LANGUAGE
SET SERVEROUTPUT ON;
--SEPUTAR MERCHANT
SELECT *
FROM MERCHANT;

INSERT INTO MERCHANT (id, name, username, password)
VALUES(NULL, 'Seblack Gila', 'seblak', 'seblak');

--REVIEWS
SELECT * 
FROM REVIEW;

-- pake pl/sql? biar customer hanya bisa 1 review per produk
INSERT INTO REVIEWS (ID, RATING, NOTE, PRODUCTS_ID, CUSTOMERS_ID)
VALUES(NULL, 1, 'ga enakk, pahittt', 1, 61);

--SEPUTAR category
SELECT *
FROM CATEGORY;

INSERT INTO CATEGORY(ID, NAME)
VALUES(NULL, 'Susu');

DELETE FROM category where id=26;

--SEPUTAR PRODUCTS
SELECT *
FROM PRODUCT;

INSERT INTO PRODUCT (ID, DESCRIPTION, TITLE, PRICE, IMAGE_URL, STOCK, CATEGORY_ID, MERCHANT_ID)
VALUES(NULL, 'Seblak super pedes', 'Seblak Gila', 15000, 'google.com', 10, 1, 21);

DELETE FROM PRODUCT WHERE ID=3;

--SEPUTAR CUSTOMER
SELECT *
FROM CUSTOMER;

INSERT INTO CUSTOMER(ID, EMAIL, USERNAME, PASSWORD, PHONE)
VALUES (null, 'WOTT@gmail.com', 'WOTT', 'passwd', '42343');

DELETE FROM CUSTOMER WHERE CUSTOMER.ID = 21;

CREATE OR REPLACE FUNCTION CREATE_CUSTOMER(L_ID IN INTEGER, L_EMAIL IN STRING, L_PASSWORD IN STRING, L_USERNAME IN STRING, L_PHONE IN STRING) RETURN NUMBER
AS
BEGIN
    INSERT INTO CUSTOMER(ID, EMAIL, USERNAME, PASSWORD, PHONE)
    VALUES (L_ID, L_EMAIL, L_USERNAME, L_PASSWORD, L_PHONE);
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RETURN 1;
    RETURN 0;
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE(CREATE_CUSTOMER(null, 'WOTT@gmail.com', 'WOTT', 'passwd', '42343'));
END;

-- SEPUTAR CARTS
SELECT *
FROM CART;

SELECT *
FROM CART_ITEM;

-- melihat keranjang belanja
SELECT * FROM CART_ITEM C
WHERE c.cart_id = (SELECT id from cart c where c.customer_id = 61);

-- tambahin item ke carts pake pl/sql?

-- PROCEDURE FUNCTION PL/SQL
CREATE OR REPLACE PROCEDURE UPDATE_CART(L_CUSTOMER_ID IN INTEGER)
IS
L_CART_ID NUMBER;
L_PRODUCT_STOCK NUMBER;
BEGIN
    SELECT ID INTO L_CART_ID
    FROM CART
    WHERE cart.customer_id = L_CUSTOMER_ID;
    
    FOR ITEM IN (SELECT * FROM CART_ITEM WHERE CART_ITEM.CART_ID = L_CART_ID) LOOP
--        DBMS_OUTPUT.PUT_LINE(ITEM.CART_ID || ' ' || ITEM.PRODUCT_ID || ' ' || ITEM.QUANTITY);
        SELECT STOCK INTO L_PRODUCT_STOCK
        FROM PRODUCT
        WHERE ID = ITEM.PRODUCT_ID;
        
        IF ITEM.QUANTITY > L_PRODUCT_STOCK THEN
            UPDATE CART_ITEM 
                SET QUANTITY = L_PRODUCT_STOCK
                WHERE CART_ITEM.CART_ID = ITEM.CART_ID;
        END IF;
    END LOOP;
END;

BEGIN
    UPDATE_CART(22);
END;

-- PROCEDURE UNTUK MENAMBAH KE CART
create or replace PROCEDURE ADD_TO_CART(L_CUSTOMER_ID IN INTEGER, L_PRODUCT_ID IN INTEGER, L_QUANTITY IN INTEGER)
IS
L_CART_ID CART.ID%TYPE;
BEGIN
    SELECT ID INTO L_CART_ID
    FROM CART
    WHERE CART.customer_id = L_CUSTOMER_ID;

    INSERT INTO CART_ITEM(CART_ID, PRODUCT_ID, QUANTITY)
    VALUES(L_CART_ID, L_PRODUCT_ID, L_QUANTITY);
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
        UPDATE CART_ITEM SET 
            QUANTITY = QUANTITY + L_QUANTITY
            WHERE ((CART_ID = L_CART_ID) AND (PRODUCT_ID = L_PRODUCT_ID));
END;

BEGIN
    ADD_TO_CART(2, 21, 1);
END;

-- PAYMENT
SELECT * FROM PAYMENT;

INSERT INTO PAYMENT(ID, METHOD, ACC_NUMBER)
VALUES (NULL, 'GOPAY', '082317900923');

-- procedure checkout
create or replace PROCEDURE CHECKOUT(L_CUSTOMER_ID IN NUMBER, L_NO_TABLE IN NUMBER, L_PAYMENT_ID IN NUMBER)
IS
L_CART_ID NUMBER;
L_PRICE NUMBER;
L_CURRENT NUMBER;
BEGIN
    -- JOIN TABLE
    -- DISTICNT
    -- MASUKIN ORDER
    SELECT ID INTO L_CART_ID
    FROM CART
    WHERE CART.customer_id = L_CUSTOMER_ID;


    FOR L_MERCHANT IN (SELECT DISTINCT MERCHANT_ID FROM (SELECT * FROM (SELECT * FROM CART_ITEM WHERE CART_ID = L_CART_ID) L_CART_ITEM INNER JOIN PRODUCT ON PRODUCT.ID = L_CART_ITEM.PRODUCT_ID)) LOOP
        INSERT INTO ORDERS(ID, STATUS, TOTAL_ITEM, TOTAL_PRICE, CUSTOMER_ID, MERCHANT_ID, PAYMENT_ID)
        VALUES(ORDER_SEQ.NEXTVAL, 0, 0, 0, L_CUSTOMER_ID, L_MERCHANT.MERCHANT_ID, 1);


        FOR ITEM IN (SELECT * FROM (SELECT * FROM CART_ITEM WHERE CART_ID = L_CART_ID) L_CART_ITEM INNER JOIN PRODUCT ON PRODUCT.ID = L_CART_ITEM.PRODUCT_ID WHERE MERCHANT_ID = L_MERCHANT.MERCHANT_ID) LOOP
            INSERT INTO ORDERS_ITEM(PRODUCT_ID, ORDERS_ID, QUANTITY)
            VALUES(ITEM.PRODUCT_ID, ORDER_SEQ.CURRVAL, ITEM.QUANTITY);

            SELECT PRICE INTO L_PRICE
            FROM PRODUCT
            WHERE PRODUCT.ID = ITEM.PRODUCT_ID;
            
            L_CURRENT := ORDER_SEQ.CURRVAL;
            
            UPDATE ORDERS SET
                TOTAL_ITEM = TOTAL_ITEM + ITEM.QUANTITY,
                TOTAL_PRICE = TOTAL_PRICE + L_PRICE
            WHERE ORDERS.ID = L_CURRENT;

            UPDATE PRODUCT SET
                STOCK = STOCK - ITEM.QUANTITY;
        END LOOP;
    END LOOP;
END;

BEGIN
    CHECKOUT(2, 10, 1);
END;

SELECT * FROM ORDERS;

SELECT * FROM ORDERS_ITEM;

DELETE FROM ORDERS WHERE id=8;



-- TRIGGER
create or replace TRIGGER create_cart
AFTER INSERT ON customer
FOR EACH ROW
BEGIN
    INSERT INTO CART(ID, TOTAL_ITEM, TOTAL_PRICE, CUSTOMER_ID)
    VALUES(NULL, 0, 0, :new.id);
END;

--CREATE OR REPLACE TRIGGER UPDATE_CART
--BEFORE SELECT ON CART_ITEMS
--FOR EACH ROW
--BEGIN 
--    


    

    


