CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    country VARCHAR(50),
    age INT,
    signup_date DATE,
    marketing_opt_in BOOLEAN
);

CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    customer_id INT,
    start_time DATETIME,
    device VARCHAR(50),
    source VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category VARCHAR(100),
    name VARCHAR(150),
    price_usd DECIMAL(10,2),
    cost_usd DECIMAL(10,2),
    margin_usd DECIMAL(10,2)
);

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    session_id INT,
    timestamp DATETIME,
    event_type VARCHAR(30),
    product_id INT,
    qty INT,
    cart_size INT,
    payment VARCHAR(30),     -- FIXED HERE
    discount_pct DECIMAL(5,2),
    amount_usd DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_time DATETIME,
    payment_method VARCHAR(50),
    discount_pct DECIMAL(5,2),
    subtotal_usd DECIMAL(10,2),
    total_usd DECIMAL(10,2),
    country VARCHAR(50),
    device VARCHAR(50),
    source VARCHAR(50)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    unit_price_usd DECIMAL(10,2),
    quantity INT,
    line_total_usd DECIMAL(10,2)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    rating INT,
    review_text TEXT,
    review_time DATETIME
);