-- 1.Display employee names with their department names
SELECT e.emp_name, d.dept_name
FROM employee e
JOIN department d
ON e.dept_id = d.dept_id;

-- 2.Count employees in each department
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM department d
JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING COUNT(e.emp_id) > 1;

-- 3.Top 3 highest paid employees with department names
SELECT e.emp_name, e.salary, d.dept_name
FROM employee e
JOIN department d
ON e.dept_id = d.dept_id
ORDER BY e.salary DESC
LIMIT 3;

-- 4. Display all departments and the employees working in them
SELECT d.dept_name, e.emp_name
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id;

-- 5. Display all employees with their department names
SELECT e.emp_name, d.dept_name
FROM employee e
LEFT JOIN department d
ON e.dept_id = d.dept_id;

-- 6. Total hours worked on each project ordered by highest hours
SELECT p.project_name, SUM(w.hours) AS total_hours
FROM project p
JOIN works_on w
ON p.project_id = w.project_id
GROUP BY p.project_name
ORDER BY total_hours DESC;

-- 7. Average salary per department (avg > 6000)
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM department d
JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 6000;
