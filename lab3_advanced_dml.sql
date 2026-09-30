
-- Laboratory Work #3 - Advanced DML Operations
-- Part A: Database and Table Setup
-- 1. Create database and tables

DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
                             dept_id SERIAL PRIMARY KEY,
                             dept_name VARCHAR(100) NOT NULL,
                             budget INTEGER,
                             manager_id INTEGER
);

CREATE TABLE employees (
                           emp_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50) NOT NULL,
                           last_name VARCHAR(50) NOT NULL,
                           department VARCHAR(100) DEFAULT 'General',
                           salary INTEGER DEFAULT 40000,
                           hire_date DATE DEFAULT CURRENT_DATE,
                           status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100) NOT NULL,
                          dept_id INTEGER REFERENCES departments(dept_id),
                          start_date DATE,
                          end_date DATE,
                          budget INTEGER
);

-- Part B: Advanced INSERT Operations
-- 2. INSERT with column specification
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'John', 'Doe', 'IT');

-- 3. INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Jane', 'Smith', 'HR', DEFAULT, DEFAULT);

-- 4. INSERT multiple rows in single statement
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('HR', 80000, 2),
    ('Sales', 120000, 3);

-- 5. INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alex', 'Brown', 'IT', 50000 * 1.1, CURRENT_DATE);

-- 6. INSERT from SELECT (subquery)
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

-- Part C: Complex UPDATE Operations
-- 7. UPDATE with arithmetic expressions
UPDATE employees
SET salary = salary * 1.10;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression
UPDATE employees
SET department = CASE
                     WHEN salary > 80000 THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
    END;

-- 10. UPDATE with DEFAULT
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery
UPDATE departments d
SET budget = (
    SELECT ROUND(AVG(e.salary) * 1.20)
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department = d.dept_name
);

-- 12. UPDATE multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D: Advanced DELETE Operations
-- 13. DELETE with simple WHERE condition
DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT d.dept_id
    FROM departments d
             JOIN employees e ON e.department = d.dept_name
    WHERE e.department IS NOT NULL
);

-- 16. DELETE with RETURNING clause
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E: Operations with NULL Values
-- 17. INSERT with NULL values
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Michael', 'Scott', NULL, NULL);

-- 18. UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- Part F: RETURNING Clause Operations
-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('David', 'Miller', 'IT', 65000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- 21. UPDATE with RETURNING
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

-- 22. DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Part G: Advanced DML Patterns
-- 23. Conditional INSERT
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Alice', 'Green', 'Finance', 70000
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Alice' AND last_name = 'Green'
);

-- 24. UPDATE with JOIN logic using subqueries
UPDATE employees e
SET salary = salary * (
    CASE
        WHEN EXISTS (
            SELECT 1 FROM departments d
            WHERE d.dept_name = e.department AND d.budget > 100000
        ) THEN 1.10
        ELSE 1.05
        END
    );

-- 25. Bulk operations
INSERT INTO employees (first_name, last_name, department, salary)
VALUES
    ('Test1', 'Bulk', 'IT', 50000),
    ('Test2', 'Bulk', 'IT', 52000),
    ('Test3', 'Bulk', 'HR', 48000),
    ('Test4', 'Bulk', 'Sales', 55000),
    ('Test5', 'Bulk', 'Sales', 51000);

UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Bulk';

-- 26. Data migration simulation
CREATE TABLE IF NOT EXISTS employee_archive (LIKE employees INCLUDING ALL);

WITH moved_rows AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_rows;

-- 27. Complex business logic
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND p.dept_id IN (
    SELECT d.dept_id
    FROM departments d
    JOIN employees e ON e.department = d.dept_name
    GROUP BY d.dept_id
    HAVING COUNT(e.emp_id) > 3
);