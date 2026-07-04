# Practical Exrcise - Advanced Database Operations

In this practical exercise, I hoped to gain insights that would enhance my ability to manage data integrity and automate processes in future projects. I faced challenges with MySQL's error management, initially using TRY/CATCH before adapting to handlers, which ultimately deepened my understanding of robust database operations.

## Other Files

As always, I have included the local MySQL database files as well as the solution file from the course page in the root project directory. I have, however, realised that github isn't allowing you to read these documents while still looking at the repo tree, presumably because I'm not naming the documents as readme.

### Triggers

I ran the following script to satisfy the requirements for the first task:

CREATE TABLE employees(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50),
	salary DECIMAL,
	department VARCHAR(50)
);

CREATE TABLE audit_log(
	entry INT AUTO_INCREMENT PRIMARY KEY,
	employee_id INT NOT NULL,
	change_date TIMESTAMP DEFAULT NOW(),
	old_salary DECIMAL,
	new_salary DECIMAL
);

INSERT INTO employees (name, salary, department)
VALUES
	('John Doe', 10000, 'Sales'),
	('Jane Smith', 200000.56, 'Development');

DELIMITER //

CREATE TRIGGER salary_update_trigger
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Check if the salary is changing
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO audit_log (employee_id, change_date, old_salary, new_salary)
        VALUES (OLD.id, NOW(), OLD.salary, NEW.salary);
    END IF;
END;

//

DELIMITER ;

UPDATE employees
SET salary = salary * 1.1 WHERE department = 'Sales';

SELECT * FROM audit_log;

### Cursors

CREATE TABLE products(
	id INT AUTO_INCREMENT PRIMARY KEY,
	product_name VARCHAR(50) NOT NULL,
	price DECIMAL
);

INSERT INTO products(product_name, price)
VALUES
	('Laptop', 989.56),
	('Phone', 687.37),
	('Graphics Tablet', 586.70);

DELIMITER //

CREATE PROCEDURE discount_high_prices()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE prod_id INT;
    DECLARE prod_price DECIMAL(10, 2);

    -- Declare a cursor for products with price > 100
    DECLARE product_cursor CURSOR FOR
        SELECT id, price FROM products WHERE price > 100;

    -- Declare a NOT FOUND handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN product_cursor;

    read_loop: LOOP
        FETCH product_cursor INTO prod_id, prod_price;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Update the product price with a 10% discount
        UPDATE products
        SET price = prod_price * 0.9
        WHERE id = prod_id;
    END LOOP read_loop;

    CLOSE product_cursor;
END;
//

DELIMITER ;

-- Check prices before running the procedure
SELECT * FROM products;
-- Run the procedure
CALL discount_high_prices();
-- Check prices after running the procedure
SELECT * FROM products;

I ran the above script to satisfy the requirements of the second task. While doing so, I noticed that the results set was automatically normalising my decimal prices to a whole number. However, this was not a part of the task to sort out and the obvious fixes I was trying were taking too long to find a working one so I moved on.

### Dynamic SQL


CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_number INT NOT NULL,
    amount INT
);

CREATE TABLE error_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    error_message VARCHAR(255) NOT NULL,
    error_time TIMESTAMP DEFAULT NOW()
);

DELIMITER //

CREATE PROCEDURE process_transaction(
    IN p_account_number INT,
    IN p_amount INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE err_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 err_message = MESSAGE_TEXT;
        INSERT INTO error_log (error_message) VALUES (CONCAT('Error processing transaction for account: ', p_account_number, ' - Error: ', err_message));
    END;

    INSERT INTO transactions (account_number, amount)
    VALUES (p_account_number, p_amount);
END;//

DELIMITER ;

CALL process_transaction(123456, 150);
CALL process_transaction(123456, 150);

SELECT * FROM transactions;
SELECT * FROM error_log;

The above is my new script for the final task of this exercise. I spent a long time trying to do this via try/catch, but then discovered that MySQL doesn't use try/catch, but uses handlers instead. The following is the try/catch block I used initially:

    BEGIN TRY
        INSERT INTO transactions (account_number, amount)
        VALUES (p_account_number, p_amount);
    END TRY
    BEGIN CATCH
        SET err_message = ERROR_MESSAGE();  -- Hypothetical function to get the error message
        INSERT INTO error_log (error_message) VALUES (CONCAT('Error processing transaction for account: ', p_account_number, ' - Error: ', err_message));
    END CATCH;


END;I also realised on testing the final script that my script was actually completely immune to errors from duplicate entries, due to the lack of unique fields besides the auto incrementing primary key, so I added a UNIQUE constraint to the account number field and ran the script again, which returned the expected error and inserted it into the error log table.
