CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) 
);

CREATE TABLE tables (
    table_id SERIAL PRIMARY KEY,
    table_number INT UNIQUE NOT NULL,
    capacity INT NOT NULL,
    status VARCHAR(20) CHECK (status IN ('available', 'reserved', 'occupied')) DEFAULT 'available'
);

CREATE TABLE ingredients (
    ingredient_id SERIAL PRIMARY KEY,
    ingredient_name VARCHAR(100) UNIQUE NOT NULL,
    quantity NUMERIC(10,2) NOT NULL CHECK (quantity >= 0),
    unit VARCHAR(20) NOT NULL 
);

CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price > 0)
);

CREATE TABLE recipes (
    recipe_id SERIAL PRIMARY KEY,
    item_id INT REFERENCES menu_items(item_id) ON DELETE CASCADE,
    ingredient_id INT REFERENCES ingredients(ingredient_id),
    quantity_required NUMERIC(10,2) NOT NULL CHECK (quantity_required > 0),
    UNIQUE(item_id, ingredient_id)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    table_id INT REFERENCES tables(table_id),
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' 
);

ALTER TABLE orders
ADD COLUMN customer_id INT REFERENCES customers(customer_id);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    item_id INT REFERENCES menu_items(item_id),
    quantity INT NOT NULL CHECK (quantity > 0)
);

INSERT INTO tables (table_number, capacity, status) VALUES
(1, 4, 'occupied'),
(2, 2, 'reserved'),
(3, 6, 'available'),
(4, 4, 'occupied'),
(5, 8, 'available');

INSERT INTO ingredients (ingredient_name, quantity, unit) VALUES
('Flour', 10000, 'gram'),
('Cheese', 5000, 'gram'),
('Tomato Sauce', 3000, 'gram'),
('Chicken', 4000, 'gram'),
('Beef', 3500, 'gram'),
('Onion', 2000, 'gram'),
('Pepper', 1500, 'gram');

INSERT INTO menu_items (item_name, price) VALUES
('Pizza', 120),
('Chicken Sandwich', 80),
('Beef Burger', 100);

INSERT INTO recipes (item_id, ingredient_id, quantity_required) VALUES
(1, 1, 200),  
(1, 2, 150),  
(1, 3, 100);  

INSERT INTO recipes (item_id, ingredient_id, quantity_required) VALUES
(2, 4, 150),  
(2, 6, 50),   
(2, 7, 20);   

INSERT INTO recipes (item_id, ingredient_id, quantity_required) VALUES
(3, 5, 200),  
(3, 6, 40),   
(3, 7, 20);  

INSERT INTO orders (table_id, status) VALUES
(1, 'pending'),
(4, 'pending');

INSERT INTO order_items (order_id, item_id, quantity) VALUES
(1, 1, 2), 
(1, 2, 1), 
(2, 3, 2); 

INSERT INTO customers (customer_name, phone) VALUES
('Ahmed Hassan', '01912345678'),
('Sara Ali', '01923456789'),
('Omar Khaled', '01934567890');

UPDATE orders SET customer_id = 1 WHERE order_id = 1;
UPDATE orders SET customer_id = 2 WHERE order_id = 2;

-- 1. Return Available Tables 
SELECT *
FROM tables
WHERE status = 'available';

-- 2. Return Each Table Linked With it's Order & Customer Name
SELECT 
    c.customer_name,
    t.table_number,
    t.status AS table_status,
    o.order_id,
    o.order_time,
    o.status AS order_status,
    m.item_name,
    oi.quantity
FROM tables t
JOIN orders o USING(table_id)
JOIN customers c USING(customer_id)
JOIN order_items oi USING(order_id)
JOIN menu_items m USING(item_id);

-- 3. Pending Orders to help Chef
SELECT 
    o.order_id,
	o.order_time,
    t.table_number,
    m.item_name,
    oi.quantity
FROM orders o
JOIN tables t USING (table_id)
JOIN order_items oi USING (order_id)
JOIN menu_items m  USING (item_id)
WHERE o.status = 'pending'
ORDER BY o.order_time ASC;

-- 4. Most Spending Customer 
SELECT 
    c.customer_name,
    SUM(m.price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o USING (customer_id) 
JOIN order_items oi USING (order_id) 
JOIN menu_items m USING (item_id) 
GROUP BY c.customer_name
ORDER BY total_spent DESC;