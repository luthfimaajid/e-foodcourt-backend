-- DATA DEFINITION LANGUAGE
-- Admin
CREATE TABLE ADMIN (
    USERNAME VARCHAR2(255 CHAR) NOT NULL,
    PASSWORD VARCHAR2(255 CHAR) NOT NULL,
    is_login NUMBER(1) DEFAULT 0 NOT NULL
);

ALTER TABLE ADMIN
    ADD CONSTRAINT ADMIN_USERNAME_UNQ UNIQUE(USERNAME);

--Merchant
CREATE TABLE merchant (
    id       INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY(START WITH 1 INCREMENT by 1),
    name     VARCHAR2(255 CHAR) NOT NULL,
    email    VARCHAR2(255 CHAR) NOT NULL,
    password VARCHAR2(255 CHAR) NOT NULL,
    status   NUMBER(1) DEFAULT 0 NOT NULL,
    phone    VARCHAR2(20 CHAR) NOT NULL,
    website  VARCHAR2(255 CHAR),
    is_login   NUMBER(1) DEFAULT 0 NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    updated_at DATE DEFAULT SYSDATE
);

ALTER TABLE merchant 
    ADD CONSTRAINT merchant_pk PRIMARY KEY ( id )
    ADD CONSTRAINT MERCHANT_NAME UNIQUE(NAME);

--category
CREATE TABLE category (
    id   INTEGER NOT NULL,
    name VARCHAR2(255 CHAR)
);
 
ALTER TABLE category 
    ADD CONSTRAINT category_pk PRIMARY KEY ( id )
    ADD CONSTRAINT CATEGORY_UNQ_NAME UNIQUE(NAME);
    
CREATE SEQUENCE CATEGORY_SEQ 
    START WITH 1
    INCREMENT BY 1;

--products
CREATE TABLE product (
    id          INTEGER NOT NULL,
    title       VARCHAR2(255 CHAR) NOT NULL,
    description VARCHAR2(4000 CHAR),
    image_url   VARCHAR2(2001 CHAR),
    price       INTEGER NOT NULL,
    stock       INTEGER NOT NULL,
    merchant_id INTEGER NOT NULL,
    created_at  DATE DEFAULT SYSDATE,
    updated_at  DATE DEFAULT SYSDATE
);

ALTER TABLE product 
    ADD CONSTRAINT product_pk PRIMARY KEY ( id )
    ADD CONSTRAINT product_merchant_fk FOREIGN KEY ( merchant_id )
        REFERENCES merchant ( id ) ON DELETE CASCADE
    ADD CONSTRAINT PRODUCT_CHK CHECK ( PRICE >= 0 AND STOCK >= 0);

CREATE SEQUENCE PRODUCT_SEQ START WITH 1;
        
-- product category m to m relation
CREATE TABLE PRODUCT_CATEGORY (
    PRODUCT_ID INTEGER,
    CATEGORY_ID INTEGER
);

ALTER TABLE PRODUCT_CATEGORY
    ADD CONSTRAINT PRODUCT_ID_FK FOREIGN KEY (PRODUCT_ID)
        REFERENCES PRODUCT (ID) ON DELETE CASCADE
    ADD CONSTRAINT CATEGORY_ID_FK FOREIGN KEY (CATEGORY_ID)
        REFERENCES CATEGORY (ID) ON DELETE CASCADE;

        
--customers
CREATE TABLE customer (
    id       INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY(START WITH 1 INCREMENT by 1),
    email    VARCHAR2(255 CHAR) NOT NULL,
    password VARCHAR2(255 CHAR) NOT NULL,
    full_name VARCHAR2(255 CHAR) NOT NULL,
    phone    VARCHAR2(15 CHAR) NOT NULL,
    gender VARCHAR2(20 CHAR) NOT NULL,
    is_login   NUMBER(1) DEFAULT 0 NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL,
    updated_at DATE DEFAULT SYSDATE NOT NULL
);

ALTER TABLE customer 
    ADD CONSTRAINT customer_pk PRIMARY KEY ( id )
    ADD CONSTRAINT EMAIL UNIQUE(EMAIL)
    ADD CONSTRAINT PHONE UNIQUE(PHONE);


--reviews
CREATE TABLE review (
    id           INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY(START WITH 1 INCREMENT by 1),
    rating       INTEGER NOT NULL,
    note         VARCHAR2(4000 CHAR),
    product_id  INTEGER NOT NULL,
    customer_id INTEGER,
    created_at  DATE DEFAULT SYSDATE,
    updated_at  DATE DEFAULT SYSDATE
);

ALTER TABLE review 
    ADD CONSTRAINT review_pk PRIMARY KEY ( id )
    ADD CONSTRAINT review_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id ) ON DELETE SET NULL
    ADD CONSTRAINT review_product_fk FOREIGN KEY ( product_id )
        REFERENCES product ( id ) ON DELETE CASCADE
    ADD CONSTRAINT REVIEW_RATING_CHK CHECK (RATING >= 1 AND RATING <= 5);

--carts
CREATE TABLE cart (
    id           INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY(START WITH 1 INCREMENT by 1),
    total_item  INTEGER NOT NULL,
    total_price INTEGER NOT NULL,
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
    quantity    INTEGER NOT NULL,
    note VARCHAR2(255 CHAR)
);

ALTER TABLE cart_item 
    ADD CONSTRAINT cart_item_pk PRIMARY KEY ( cart_id, product_id )
    ADD CONSTRAINT cart_item_cart_fk FOREIGN KEY ( cart_id )
        REFERENCES cart ( id ) ON DELETE CASCADE
    ADD CONSTRAINT cart_item_product_fk FOREIGN KEY ( product_id )
        REFERENCES product ( id ) ON DELETE CASCADE
    ADD CONSTRAINT CART_ITEM_CHK CHECK ( QUANTITY > 0 );
        
-- payment method
CREATE TABLE payment (
    id         INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY(START WITH 1 INCREMENT by 1),
    method     VARCHAR2(255 CHAR) NOT NULL,
    acc_number VARCHAR2(255 CHAR) NOT NULL,
    status NUMBER(1) DEFAULT 1 NOT NULL
);

ALTER TABLE payment 
    ADD CONSTRAINT payment_pk PRIMARY KEY ( id )
    ADD CONSTRAINT PAYMENT_METHOD UNIQUE(METHOD);

-- TABLE INVOICE
CREATE TABLE invoice (
    id          INTEGER NOT NULL,
    bill        INTEGER NOT NULL,
    fee         FLOAT(1) NOT NULL,
    customer_id INTEGER,
    payment_id  INTEGER,
    created_at  DATE DEFAULT SYSDATE
);

ALTER TABLE invoice 
    ADD CONSTRAINT invoice_pk PRIMARY KEY ( id )
    ADD CONSTRAINT invoice_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id ) ON DELETE SET NULL
    ADD CONSTRAINT invoice_payment_fk FOREIGN KEY ( payment_id )
        REFERENCES payment ( id ) ON DELETE SET NULL;

CREATE SEQUENCE INVOICE_SEQ START WITH 1;

--orders
CREATE TABLE orders (
    id          INTEGER NOT NULL,
    status      INTEGER DEFAULT 0 NOT NULL,
    total_item  INTEGER NOT NULL,
    total_price INTEGER NOT NULL,
    customer_id INTEGER,
    merchant_id INTEGER,
    invoice_id  INTEGER,
    created_at  DATE DEFAULT SYSDATE
);

ALTER TABLE orders 
    ADD CONSTRAINT orders_pk PRIMARY KEY ( id )
    ADD CONSTRAINT orders_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id ) ON DELETE SET NULL
    ADD CONSTRAINT orders_merchant_fk FOREIGN KEY ( merchant_id )
        REFERENCES merchant ( id ) ON DELETE SET NULL
    ADD CONSTRAINT orders_invoice_fk FOREIGN KEY ( invoice_id )
        REFERENCES invoice ( id ) ON DELETE SET NULL;

CREATE SEQUENCE ORDER_SEQ START WITH 1;
        
        
--orders-items
CREATE TABLE orders_item (
    orders_id   INTEGER NOT NULL,
    product_id INTEGER,
    quantity    INTEGER NOT NULL,
    note    VARCHAR2(255)
);

ALTER TABLE orders_item 
    ADD CONSTRAINT orders_item_pk PRIMARY KEY ( product_id, orders_id )
    ADD CONSTRAINT orders_item_orders_fk FOREIGN KEY ( orders_id )
        REFERENCES orders ( id ) ON DELETE CASCADE
    ADD CONSTRAINT orders_item_product_fk FOREIGN KEY ( product_id )
        REFERENCES product ( id ) ON DELETE SET NULL;
        
CREATE TYPE ARRAY_OF_INTEGER IS TABLE OF INTEGER;

