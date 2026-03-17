-- 1. Assign a row number to each task per employee ordered by due_date
SELECT emp_name, task_name, ROW_NUMBER() OVER(ORDER BY due_date) as rn
FROM tasks
JOIN employee USING (emp_id)

-- 2. Rank employees based on their salary (highest salary = rank 1).
SELECT emp_name, salary, salary_rank
FROM (
    SELECT emp_name, salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employee
) sub
WHERE salary_rank = 1;

-- 3. Show the latest task for each employee.
SELECT emp_name , task_name
FROM (
	SELECT emp_name , task_name , ROW_NUMBER() OVER(PARTITION BY emp_id ORDER BY due_date DESC) as latest_task_per_emp
	FROM employee JOIN 
	tasks USING(emp_id)
) as rn
WHERE rn.latest_task_per_emp=1

-- 4. Show each employee with the average salary of their department
SELECT emp_name, dept_name , ROUND(AVG(salary) OVER(PARTITION BY dept_id),2) as avg_salary_per_det
FROM employee 
JOIN department USING (dept_id) 

-- 5. Show running count of tasks per employee ordered by due_date.
SELECT emp_name, COUNT(task_id) OVER(PARTITION BY emp_id ORDER BY due_date) as count_tasks_per_emp
FROM employee 
JOIN tasks USING (emp_id)

-- 6. Show each employee with their rank based on salary.
SELECT emp_name,salary, DENSE_RANK() OVER(ORDER BY salary DESC) as salary_rank
FROM employee

-- 7. Show employee name and number of tasks, 
-- but only for employees whose task count is above average.
WITH task_counts AS (
    SELECT 
        e.emp_id,
        e.emp_name,
        COUNT(t.task_id) AS task_count
    FROM employee e
    JOIN tasks t USING (emp_id)
    GROUP BY e.emp_id, e.emp_name
)

SELECT emp_name, task_count
FROM task_counts
WHERE task_count > (
    SELECT AVG(task_count) FROM task_counts
);

-- 8. Rank tasks by priority (High first), without gaps in ranking.
SELECT task_name, priority, DENSE_RANK() OVER (ORDER BY 
	CASE priority
		WHEN 'High' then 1
		WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END) as priority_rank
FROM tasks

-- 9. Show the employee who has the maximum number of tasks
WITH task_count AS (
    SELECT 
        e.emp_name, 
        COUNT(t.task_id) AS number_of_tasks
    FROM tasks t
    JOIN employee e USING (emp_id)
    GROUP BY e.emp_id, e.emp_name
)


SELECT emp_name, number_of_tasks
FROM (
    SELECT *, 
           DENSE_RANK() OVER (ORDER BY number_of_tasks DESC) AS num_of_tasks_rank
    FROM task_count
) sub
WHERE num_of_tasks_rank = 1;

-- 10. Show employees who have more tasks than their manager
WITH task_count AS (
    SELECT 
        e.emp_id,
        e.manager_id,
        e.emp_name,
        COUNT(t.task_id) AS number_of_tasks
    FROM employee e
    LEFT JOIN tasks t USING (emp_id)
    GROUP BY e.emp_id, e.emp_name, e.manager_id
)

SELECT e1.emp_name AS employee_name,
       e1.number_of_tasks AS emp_tasks,
       e2.emp_name AS manager_name,
       e2.number_of_tasks AS manager_tasks
FROM task_count e1
JOIN task_count e2
  ON e1.manager_id = e2.emp_id
WHERE e1.number_of_tasks > e2.number_of_tasks;

