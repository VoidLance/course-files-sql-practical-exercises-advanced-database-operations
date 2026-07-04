-- Lesson 1: Triggers
-- Exercise 1: Create an Audit Log Using a Trigger

-- 1. Create a New Database as 'module10_db'
CREATE DATABASE module10_db;
USE module10_db;

-- 2. Create a table employees with columns id, name, salary, and department.
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    salary DECIMAL(10,2),
    department VARCHAR(50)
);


-- 3. Create a table audit_log to store changes made to the salary column in employees.
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Write a BEFORE UPDATE trigger named salary_update_trigger that logs any changes to the salary into the audit_log.
DELIMITER $$

CREATE TRIGGER salary_update_trigger
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO audit_log (employee_id, old_salary, new_salary)
        VALUES (OLD.id, OLD.salary, NEW.salary);
    END IF;
END $$

DELIMITER ;

-- 5. Test the trigger by updating the salary of an employee and verifying that the change is logged.
INSERT INTO employees (name, salary, department) VALUES ('John Doe', 5000, 'HR');
UPDATE employees SET salary = 5500 WHERE id = 1;
SELECT * FROM audit_log;


-- *******************************************************

-- Lesson 2: Cursors
-- Exercise 2: Loop Through Records with a Cursor

-- 1. Create a table products with columns id, product_name, and price.
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

-- 2. Write a stored procedure named discount_high_prices that uses a cursor to loop through products priced above 100 and reduces their prices by 10%.
DELIMITER $$

CREATE PROCEDURE discount_high_prices()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE product_id INT;
    DECLARE product_price DECIMAL(10,2);
    
    DECLARE product_cursor CURSOR FOR 
        SELECT id, price FROM products WHERE price > 100;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN product_cursor;
    
    price_loop: LOOP
        FETCH product_cursor INTO product_id, product_price;
        IF done THEN
            LEAVE price_loop;
        END IF;
        

        UPDATE products SET price = product_price * 0.9 WHERE id = product_id;
    END LOOP price_loop;
    
    CLOSE product_cursor;
END $$

DELIMITER ;

-- 3. Test the procedure by checking the price changes before and after running the cursor.
INSERT INTO products (product_name, price) VALUES ('Laptop', 150), ('Tablet', 200);
CALL discount_high_prices();
SELECT * FROM products;


-- *******************************************************


-- Lesson 3: Dynamic SQL
-- Exercise 3: Execute Dynamic SQL to Select from Any Table

-- 1. Create tables orders and customers.
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(50),
    order_amount DECIMAL(10,2)
);

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(100)
);

-- 2. Write a stored procedure named dynamic_select that takes a table name as input and dynamically selects all rows from that table.
DELIMITER $$

CREATE PROCEDURE dynamic_select(table_name VARCHAR(50))
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', table_name);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- 3. Test the procedure by passing different table names like orders and customers.
INSERT INTO orders (customer_name, order_amount) VALUES ('Alice', 100), ('Bob', 200);
INSERT INTO customers (customer_name, email) VALUES ('Alice', 'alice@example.com'), ('Bob', 'bob@example.com');

CALL dynamic_select('orders');
CALL dynamic_select('customers');



-- *******************************************************

-- Lesson 4: Handling Errors
-- Exercise 4: Handle Errors in a Stored Procedure

-- 1. Create a table transactions with columns id, account_number, and amount.
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE, 
    amount DECIMAL(10,2)
);


-- 2. Create a table error_log with columns id, error_message, and error_time to store error logs.
CREATE TABLE error_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    error_message VARCHAR(255),
    error_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Write a stored procedure process_transaction that tries to insert a record into the transactions table and logs an error in the error_log table if the transaction fails.
DELIMITER $$

CREATE PROCEDURE process_transaction(account_number VARCHAR(20), amount DECIMAL(10,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO error_log (error_message) 
        VALUES ('Transaction failed due to a SQL error');
    END;
    
    INSERT INTO transactions (account_number, amount) 
    VALUES (account_number, amount);
END $$

DELIMITER ;


-- 4. Test the procedure by attempting to insert a duplicate record and logging the error.
CALL process_transaction('1234567890', 500);
CALL process_transaction('1234567890', 500);
SELECT * FROM transactions;
SELECT * FROM error_log;
