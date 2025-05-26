--a)
SELECT eid, ename, address
FROM employee
WHERE age BETWEEN lower AND upper;

CREATE INDEX age_idx ON employee (age);
-- binary tree

--b)
SELECT id, address
FROM employee
WHERE name = given_name;

CREATE INDEX balance_idx ON employee USING HASH (name);

--c)
SELECT max(salary)
FROM employee;

--Index on salary binary tree

CREATE INDEX salary_idx ON employee (salary);

--d)
SELECT avg(salary)
FROM employee
GROUP BY age;


Index on age
Btree
CREATE INDEX d_idx ON employee (age); -- easy
CREATE INDEX d_idx ON employee (age, salary); -- better


SELECT locality, COUNT(*)
FROM transformer
         NATURAL JOIN substation
WHERE pv = 630
GROUP BY locality;


SELECT id, description
FROM incident
WHERE instant BETWEEN '2020-02-26 09:55:08.000000' AND '2020-09-20 16:34:02.000000'
AND description LIKE '______';


SELECT branch_name
from account
where balance = 3000
GROUP BY branch_name;

SELECT account_number, branch_name
from account
where balance  between 3000 and 5500 and branch_name like '______';

CREATE index bal on account(balance);
CREATE index bal on account using hash(balance);
CREATE INDEX br on account(branch_name);
CREATE INDEX only_i on account(balance, branch_name, account_number);
drop index bal;
drop index br;
drop index only_i;