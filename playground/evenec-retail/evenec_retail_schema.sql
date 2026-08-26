CREATE TABLE customers(customer_id INTEGER PRIMARY KEY,first_name TEXT,last_name TEXT,city TEXT,signup_date DATE);
CREATE TABLE orders(order_id INTEGER PRIMARY KEY,customer_id INTEGER,order_date DATE,amount REAL,status TEXT);
CREATE TABLE products(product_id INTEGER PRIMARY KEY,product_name TEXT,category TEXT,price REAL);
CREATE TABLE order_items(order_item_id INTEGER PRIMARY KEY,order_id INTEGER,product_id INTEGER,quantity INTEGER,unit_price REAL);
CREATE TABLE payments(payment_id INTEGER PRIMARY KEY,order_id INTEGER,payment_method TEXT,amount REAL,payment_status TEXT);
CREATE TABLE employees(employee_id INTEGER PRIMARY KEY,first_name TEXT,last_name TEXT,department TEXT,hire_date DATE);
