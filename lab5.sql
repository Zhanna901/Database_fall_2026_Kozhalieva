/*******************************************************************************
  LABORATORY WORK 5: DATABASE CONSTRAINTS
  Student Name: Жанна
  Student ID: 25B031344
*******************************************************************************/

--------------------------------------------------------------------------------
-- PART 1: CHECK Constraints
--------------------------------------------------------------------------------

-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
                           employee_id INT,
                           first_name TEXT,
                           last_name TEXT,
                           age INT CHECK (age BETWEEN 18 AND 65),
                           salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog (
                                  product_id INT,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,
                                  CONSTRAINT valid_discount CHECK (
                                      regular_price > 0
                                          AND discount_price > 0
                                          AND discount_price < regular_price
                                      )
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings (
                          booking_id INT,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INT CHECK (num_guests BETWEEN 1 AND 10),
                          CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK Constraints

-- 1. Valid Data
INSERT INTO employees VALUES (1, 'John', 'Doe', 30, 50000);
INSERT INTO employees VALUES (2, 'Jane', 'Smith', 45, 65000);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000, 850);
INSERT INTO products_catalog VALUES (2, 'Mouse', 50, 40);

INSERT INTO bookings VALUES (1, '2026-10-10', '2026-10-15', 2);
INSERT INTO bookings VALUES (2, '2026-11-01', '2026-11-05', 4);

-- 2 & 3. Invalid Data Attempts (Commented out to allow script execution)

-- Violates age CHECK (age < 18)
-- INSERT INTO employees VALUES (3, 'Young', 'User', 17, 30000);

-- Violates salary CHECK (salary <= 0)
-- INSERT INTO employees VALUES (4, 'Low', 'Paid', 25, 0);

-- Violates valid_discount CHECK (discount_price >= regular_price)
-- INSERT INTO products_catalog VALUES (3, 'Keyboard', 100, 120);

-- Violates bookings_num_guests_check (num_guests > 10)
-- INSERT INTO bookings VALUES (3, '2026-10-10', '2026-10-12', 12);

-- Violates date CHECK (check_out_date <= check_in_date)
-- INSERT INTO bookings VALUES (4, '2026-10-15', '2026-10-10', 2);


--------------------------------------------------------------------------------
-- PART 2: NOT NULL Constraints
--------------------------------------------------------------------------------

-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
                           customer_id INT NOT NULL,
                           email TEXT NOT NULL,
                           phone TEXT, -- can be NULL
                           registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
                           item_id INT NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INT NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL

-- 1. Complete records
INSERT INTO customers VALUES (1, 'alice@example.com', '+123456789', '2026-01-10');
INSERT INTO inventory VALUES (101, 'Monitor', 50, 199.99, NOW());

-- 2. NULL in nullable column (phone is NULL)
INSERT INTO customers VALUES (2, 'bob@example.com', NULL, '2026-02-15');

-- 3. Failed attempt: NULL in NOT NULL column
-- INSERT INTO customers VALUES (3, NULL, '+987654321', '2026-03-01');
-- Reason: column "email" violates not-null constraint


--------------------------------------------------------------------------------
-- PART 3: UNIQUE Constraints
--------------------------------------------------------------------------------

-- Task 3.1 & 3.3: Single Column & Named UNIQUE Constraints
CREATE TABLE users (
                       user_id INT,
                       username TEXT,
                       email TEXT,
                       created_at TIMESTAMP,
                       CONSTRAINT unique_username UNIQUE (username),
                       CONSTRAINT unique_email UNIQUE (email)
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
                                    enrollment_id INT,
                                    student_id INT,
                                    course_code TEXT,
                                    semester TEXT,
                                    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);

-- Testing UNIQUE constraints
INSERT INTO users VALUES (1, 'johndoe', 'john@example.com', NOW());

-- Attempt duplicate username:
-- INSERT INTO users VALUES (2, 'johndoe', 'other@example.com', NOW());
-- Reason: Key (username)=(johndoe) already exists.

-- Attempt duplicate enrollment combination:
INSERT INTO course_enrollments VALUES (1, 101, 'CS101', 'Fall2026');
-- INSERT INTO course_enrollments VALUES (2, 101, 'CS101', 'Fall2026');
-- Reason: Key (student_id, course_code, semester)=(101, CS101, Fall2026) already exists.


--------------------------------------------------------------------------------
-- PART 4: PRIMARY KEY Constraints
--------------------------------------------------------------------------------

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES (1, 'Computer Science', 'Building A');
INSERT INTO departments VALUES (2, 'Mathematics', 'Building B');
INSERT INTO departments VALUES (3, 'Sociology', 'Building C');

-- Attempt duplicate dept_id
-- INSERT INTO departments VALUES (1, 'Physics', 'Building D');
-- Error: duplicate key value violates unique constraint "departments_pkey"

-- Attempt NULL dept_id
-- INSERT INTO departments VALUES (NULL, 'Chemistry', 'Building E');
-- Error: null value in column "dept_id" violates not-null constraint

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
                                 student_id INT,
                                 course_id INT,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 PRIMARY KEY (student_id, course_id)
);

-- Task 4.3: Comparison Exercise (Documentation)
/*
  --- UNIQUE vs PRIMARY KEY Comparison ---
  1. Difference:
     - A PRIMARY KEY uniquely identifies each record and implicitly enforces NOT NULL.
     - A UNIQUE constraint ensures all values in a column are distinct, but allows NULL values
       (unless defined with NOT NULL).

  2. Single-column vs Composite PRIMARY KEY:
     - Use Single-column PK when an entity has a standalone natural or surrogate identifier (e.g., student_id).
     - Use Composite PK when an entity is defined by a combination of relationships or attributes
       (e.g., junction tables like student_courses where the pair (student_id, course_id) is unique).

  3. Multiple UNIQUE vs Single PRIMARY KEY:
     - A table can have only ONE PRIMARY KEY because it defines the fundamental physical / logical identity of a row.
     - A table can have MULTIPLE UNIQUE constraints to prevent duplication in secondary attributes (e.g., username, SSN, email).
*/


--------------------------------------------------------------------------------
-- PART 5: FOREIGN KEY Constraints
--------------------------------------------------------------------------------

-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
                                emp_id INT PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INT REFERENCES departments(dept_id),
                                hire_date DATE
);

-- Valid insert
INSERT INTO employees_dept VALUES (101, 'Alice', 1, '2026-09-01');

-- Attempt inserting non-existent dept_id
-- INSERT INTO employees_dept VALUES (102, 'Bob', 99, '2026-09-01');
-- Error: insert or update on table "employees_dept" violates foreign key constraint

-- Task 5.2: Multiple Foreign Keys
CREATE TABLE authors (
                         author_id INT PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INT PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INT PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INT REFERENCES authors(author_id),
                       publisher_id INT REFERENCES publishers(publisher_id),
                       publication_year INT,
                       isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'Abai Kunanbayev', 'Kazakhstan');
INSERT INTO publishers VALUES (1, 'Almaty Print', 'Almaty');
INSERT INTO books VALUES (101, 'Words of Edification', 1, 1, 1890, '978-0123456789');

-- Task 5.3: ON DELETE Options
CREATE TABLE categories (
                            category_id INT PRIMARY KEY,
                            category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
                             product_id INT PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INT REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders_fk (
                           order_id INT PRIMARY KEY,
                           order_date DATE NOT NULL
);

CREATE TABLE order_items (
                             item_id INT PRIMARY KEY,
                             order_id INT REFERENCES orders_fk(order_id) ON DELETE CASCADE,
                             product_id INT REFERENCES products_fk(product_id),
                             quantity INT CHECK (quantity > 0)
);

-- Testing ON DELETE behaviors
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (10, 'Smartphone', 1);

INSERT INTO orders_fk VALUES (1001, '2026-10-01');
INSERT INTO order_items VALUES (1, 1001, 10, 2);

-- Scenario 1: Try deleting a category with referenced products (ON DELETE RESTRICT)
-- DELETE FROM categories WHERE category_id = 1;
-- Outcome: FAILS. update or delete on table "categories" violates foreign key constraint on table "products_fk".

-- Scenario 2: Delete an order with related order_items (ON DELETE CASCADE)
DELETE FROM orders_fk WHERE order_id = 1001;
-- Outcome: SUCCESS. Deleting order 1001 automatically removes item 1 from order_items.


--------------------------------------------------------------------------------
-- PART 6: Practical Application (E-commerce Schema)
--------------------------------------------------------------------------------

-- 1. Table Definitions
CREATE TABLE customers_ecom (
                                customer_id INT PRIMARY KEY,
                                name TEXT NOT NULL,
                                email TEXT UNIQUE NOT NULL,
                                phone TEXT,
                                registration_date DATE NOT NULL
);

CREATE TABLE products_ecom (
                               product_id INT PRIMARY KEY,
                               name TEXT NOT NULL,
                               description TEXT,
                               price NUMERIC NOT NULL CHECK (price >= 0),
                               stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders_ecom (
                             order_id INT PRIMARY KEY,
                             customer_id INT NOT NULL REFERENCES customers_ecom(customer_id) ON DELETE RESTRICT,
                             order_date DATE NOT NULL,
                             total_amount NUMERIC CHECK (total_amount >= 0),
                             status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details_ecom (
                                    order_detail_id INT PRIMARY KEY,
                                    order_id INT REFERENCES orders_ecom(order_id) ON DELETE CASCADE,
                                    product_id INT REFERENCES products_ecom(product_id) ON DELETE RESTRICT,
                                    quantity INT NOT NULL CHECK (quantity > 0),
                                    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- 2. Sample Data (5 records per table)
INSERT INTO customers_ecom VALUES
                               (1, 'John Doe', 'john.d@example.com', '+1111111', '2026-01-01'),
                               (2, 'Jane Smith', 'jane.s@example.com', '+2222222', '2026-01-02'),
                               (3, 'Alex Wong', 'alex.w@example.com', NULL, '2026-01-03'),
                               (4, 'Maria Garcia', 'maria.g@example.com', '+4444444', '2026-01-04'),
                               (5, 'Dmitry Ivanov', 'dmitry.i@example.com', '+5555555', '2026-01-05');

INSERT INTO products_ecom VALUES
                              (101, 'Wireless Mouse', 'Ergonomic optical mouse', 25.50, 100),
                              (102, 'Mechanical Keyboard', 'RGB backlight switch', 89.99, 50),
                              (103, 'HD Monitor', '27 inch IPS panel', 199.99, 30),
                              (104, 'USB Cable', 'Type-C to Type-C 2m', 9.99, 200),
                              (105, 'Gaming Headset', '7.1 Surround Sound', 59.99, 40);

INSERT INTO orders_ecom VALUES
                            (501, 1, '2026-10-01', 115.49, 'delivered'),
                            (502, 2, '2026-10-02', 199.99, 'shipped'),
                            (503, 3, '2026-10-03', 25.50, 'processing'),
                            (504, 4, '2026-10-04', 9.99, 'pending'),
                            (505, 5, '2026-10-05', 149.98, 'cancelled');

INSERT INTO order_details_ecom VALUES
                                   (1001, 501, 101, 1, 25.50),
                                   (1002, 501, 102, 1, 89.99),
                                   (1003, 502, 103, 1, 199.99),
                                   (1004, 503, 101, 1, 25.50),
                                   (1005, 505, 105, 2, 59.99);

-- 3. Test Queries for E-commerce Constraints

-- Test Invalid Status Value:
-- INSERT INTO orders_ecom VALUES (506, 1, '2026-10-06', 50.00, 'in_transit');
-- Reason: check constraint "orders_ecom_status_check" is violated

-- Test Negative Price:
-- INSERT INTO products_ecom VALUES (106, 'Defective Item', 'Desc', -5.00, 10);
-- Reason: check constraint "products_ecom_price_check" is violated

-- Test Duplicate Email:
-- INSERT INTO customers_ecom VALUES (6, 'Duplicate User', 'john.d@example.com', NULL, '2026-02-01');
-- Reason: key value violates unique constraint "customers_ecom_email_key"

-- Test Deleting Customer with Orders (ON DELETE RESTRICT):
-- DELETE FROM customers_ecom WHERE customer_id = 1;
-- Reason: update or delete on table "customers_ecom" violates foreign key constraint on table "orders_ecom"