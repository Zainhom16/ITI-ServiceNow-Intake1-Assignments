-- 1. For each department, show the latest hired employee (based on hire_date).
SELECT d.dept_name, e.emp_name, e.hire_date
FROM department d
JOIN employee e 
ON d.dept_id = e.dept_id
WHERE e.hire_date = (
    SELECT MAX(e2.hire_date)
    FROM employee e2
    WHERE e2.dept_id = d.dept_id
);

-- OTHER SOLUTION
SELECT d.dept_name, e.emp_name, e.hire_date
FROM department d
JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name, e.emp_name, e.hire_date
HAVING e.hire_date = MAX(e.hire_date);

-- 2. Display all employees with their department names using a NATURAL JOIN.
SELECT e.emp_name, d.dept_name
FROM employee e 
NATURAL JOIN department d


-- 3. Show each project and its budget, along with the number of employees working on it (assuming a works_on table exists).
SELECT p.project_name, p.project_id, p.budget, COUNT(w.emp_id) AS num_of_employees
FROM projects p
JOIN works_on w ON p.project_id = w.project_id
GROUP BY p.project_name, p.project_id, p.budget;

-- 4. List all employees who have the same salary, without repeating pairs .
SELECT e1.emp_name, e2.emp_name, e1.salary
FROM employee e1
JOIN employee e2
ON e1.salary = e2.salary
AND e1.emp_id < e2.emp_id;

-- 5. Show project name with the employees working on it (assuming a works_on table exists).
SELECT p.project_name, p.project_id, e.emp_name
FROM projects p
JOIN works_on w ON p.project_id = w.project_id
JOIN employee e on e.emp_id = w.emp_id

-- 6. Show names of employees and departments full join
SELECT e.emp_name, d.dept_name
FROM employee e
FULL JOIN department d
ON e.dept_id = d.dept_id;

-- 7. For each department, show one employee (any employee) in that department
SELECT dept_name, emp_name
FROM (
    SELECT d.dept_name, e.emp_name,
           ROW_NUMBER() OVER(PARTITION BY d.dept_id ORDER BY e.emp_name) AS rn
    FROM department d
    LEFT JOIN employee e ON d.dept_id = e.dept_id
) t
WHERE rn = 1;

-- 8. Show department name and average salary of employees in that department (use subquery).
SELECT d.dept_name, ROUND(AVG(e.salary),2) AS avg_salary
FROM department d
LEFT JOIN LATERAL (
    SELECT salary
    FROM employee e
    WHERE e.dept_id = d.dept_id
) e ON true
GROUP BY d.dept_name;

-- 9. Show employees who were hired on the same date.
SELECT e1.emp_name, e2.emp_name, e1.hire_date
FROM employee e1
JOIN employee e2
ON e1.hire_date = e2.hire_date
AND e1.emp_id < e2.emp_id;

-- 10. Show employees whose salary is greater than the average salary.
SELECT e.emp_name
FROM employee e 
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employee
);