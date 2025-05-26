/* JOINS 101
 SELECT *
 FROM account as a NATURAL JOIN branch b on a.branch_name = b.branch_name;
 
 SELECT *
 FROM account INNER JOIN branch on account.branch_name = branch.branch_name;
 
 SELECT *
 FROM account RIGHT OUTER JOIN branch on account.branch_name = branch.branch_name;
 
 */
--Question 1
--a)
SELECT DISTINCT customer_name
FROM customer
WHERE customer_city IN (
        SELECT branch_city
        FROM branch
    );
--b)
SELECT DISTINCT customer_name
FROM customer
WHERE customer_name NOT IN(
        SELECT customer_name
        FROM borrower
    )
    AND customer_name IN(
        SELECT customer_name
        FROM depositor
    );
--c)
SELECT DISTINCT customer_name
FROM customer
    NATURAL JOIN borrower
    NATURAL JOIN loan
    NATURAL JOIN branch
WHERE customer_city = branch_city;
--d)
SELECT DISTINCT customer_name
FROM customer
WHERE customer_name IN (
        SELECT customer_name
        FROM borrower
    )
    AND customer_name IN (
        SELECT customer_name
        FROM depositor
    );
--Second Option
SELECT DISTINCT customer_name
FROM depositor
    NATURAL JOIN borrower;
-- Question 2
-- a)
SELECT SUM(balance)
FROM account
    NATURAL JOIN branch
WHERE branch_city = 'Amadora';
-- b)
SELECT MAX(balance)
FROM account
    NATURAL JOIN branch
WHERE branch_city = 'Amadora';
-- c)
SELECT COUNT(DISTINCT customer)
FROM customer
    NATURAL JOIN depositor
    NATURAL JOIN account
    NATURAL JOIN branch
WHERE customer_city = branch_city;
-- d)
SELECT COUNT(customer_name) AS num_cli
FROM customer
WHERE customer_name NOT IN (
        SELECT customer_name
        FROM borrower
    )
    AND customer_name IN (
        SELECT customer_name
        FROM depositor
    );
-- Second Option
SELECT count(DISTINCT customer_name)
FROM depositor
WHERE customer_name NOT IN(
        SELECT customer_name
        FROM borrower
    );
-- Question 3
-- a)
-- IF customer_city
SELECT MAX(balance),
    customer_city
FROM account
    NATURAL JOIN depositor
    NATURAL JOIN customer
GROUP BY customer_city;
-- if branch_city
SELECT MAX(balance),
    branch_city
FROM account
    NATURAL JOIN branch
GROUP BY branch_city;
--b)
--if customer_city
SELECT AVG(balance),
    customer_city
FROM account
    NATURAL JOIN depositor
    NATURAL JOIN customer
GROUP BY customer_city;
-- if branch_city
SELECT AVG(balance) as balance,
    branch_city as city
FROM account
    NATURAL JOIN branch
GROUP BY branch_city;
--c)
SELECT COUNT(account),
    branch_name
FROM account
GROUP BY branch_name;
--Showing nulls
SELECT COUNT(DISTINCT account_number),
    b.branch_name
FROM account a
    RIGHT OUTER JOIN branch b ON a.branch_name = b.branch_name
GROUP BY b.branch_name;
--d)
SELECT COUNT(account),
    branch_city
FROM account
    NATURAL JOIN branch
GROUP BY branch_city;
/* Help Queries
 SELECT *
 FROM account NATURAL JOIN depositor NATURAL JOIN customer;
 */
--e)
SELECT SUM(balance),
    customer_name
FROM account
    NATURAL JOIN depositor
    NATURAL JOIN customer
GROUP BY customer_name;
--More complicated
SELECT c.customer_name,
    sum(balance)
FROM depositor d
    INNER JOIN account a ON d.account_number = a.account_number
    RIGHT OUTER JOIN customer c ON c.customer_name = d.customer_name
GROUP BY c.customer_name;
--f)
SELECT COUNT(loan_number),
    customer_name
FROM loan
    NATURAL JOIN borrower
GROUP BY customer_name
HAVING COUNT(loan_number) >= 2;
--e)
SELECT COUNT(*),
    customer_name
FROM account a
    NATURAL JOIN depositor
GROUP BY customer_name
HAVING COUNT(*) >= 2
ORDER BY customer_name ASC;
--DSC for descending order
--Question 4
--a)
SELECT b.branch_name
FROM branch b
WHERE b.assets < (
        SELECT sum(amount)
        FROM loan l
        WHERE b.branch_name = l.branch_name
    );
--b)
SELECT b.branch_name
FROM branch b
    INNER JOIN account a ON b.branch_name = a.branch_name
GROUP BY b.branch_name
HAVING SUM(a.balance) < (
        SELECT sum(amount)
        FROM loan l
        WHERE b.branch_name = l.branch_name
    );
--c)
SELECT b.branch_name,
    COALESCE(SUM(a.balance), 0) - COALESCE(
        (
            SELECT SUM(l.amount)
            FROM loan l
            WHERE b.branch_name = l.branch_name
        ),
        0
    ) as diff
FROM account a
    RIGHT OUTER JOIN branch b ON b.branch_name = a.branch_name
GROUP BY b.branch_name;

--professor way
SELECT b.branch_name,
    total_assets - total_liabilities
FROM branch b
    INNER JOIN (
        SELECT branch_name,
            SUM(balance) as total_assets
        FROM account
        GROUP BY branch_name
    ) a ON a.branch_name = b.branch_name
    INNER JOIN (
        SELECT branch_name,
            SUM(amount) as total_liabilities
        FROM loan
        GROUP BY branch_name
    ) l ON l.branch_name = b.branch_name;
--d)
SELECT c.customer_name,
    COALESCE(
        (
            SELECT SUM(a.balance)
            FROM account a
                INNER JOIN depositor d ON d.account_number = a.account_number
            WHERE d.customer_name = c.customer_name
        ),
        0
    ) ,COALESCE(
        (
            SELECT SUM(l.amount)
            FROM loan l
                INNER JOIN borrower b ON b.loan_number = l.loan_number
            WHERE b.customer_name = c.customer_name
        ),
        0
    )
FROM customer c;
--Another way
SELECT c.customer_name,
    COALESCE(SUM(a.balance), 0) - COALESCE(
        (
            SELECT SUM(l.amount)
            FROM loan l
                INNER JOIN borrower b ON b.loan_number = l.loan_number
            WHERE b.customer_name = c.customer_name
        ),
        0
    )
FROM customer c
    LEFT OUTER JOIN depositor d ON c.customer_name = d.customer_name
    LEFT OUTER JOIN account a ON a.account_number = d.account_number
GROUP BY c.customer_name;
--e)
SELECT c.customer_name
FROM customer c
    LEFT OUTER JOIN depositor d ON c.customer_name = d.customer_name
    LEFT OUTER JOIN account a ON a.account_number = d.account_number
GROUP BY c.customer_name
HAVING COALESCE(SUM(a.balance), 0) < COALESCE(
        (
            SELECT SUM(l.amount)
            FROM loan l
                INNER JOIN borrower b ON b.loan_number = l.loan_number
            WHERE b.customer_name = c.customer_name
        ),
        0
    );
--another way
SELECT c.customer_name
FROM customer c
GROUP BY c.customer_name
HAVING COALESCE(
        (
            SELECT SUM(a.balance)
            FROM account a
                INNER JOIN depositor d ON d.account_number = a.account_number
            WHERE d.customer_name = c.customer_name
        ),
        0
    ) < COALESCE(
        (
            SELECT SUM(l.amount)
            FROM loan l
                INNER JOIN borrower b ON b.loan_number = l.loan_number
            WHERE b.customer_name = c.customer_name
        ),
        0
    );
--Question 5
--a)
SELECT c.customer_name,
    SUM(l.amount)
FROM customer c
    INNER JOIN borrower b ON b.customer_name = c.customer_name
    INNER JOIN loan l ON b.loan_number = l.loan_number
GROUP BY c.customer_name
HAVING SUM(l.amount) >= ALL(
        SELECT SUM(l.amount)
        FROM loan l
            INNER JOIN borrower b ON b.loan_number = l.loan_number
        GROUP BY b.customer_name
    );
--b)
SELECT a.branch_name,
    COUNT(*)
FROM account a
GROUP BY a.branch_name
HAVING COUNT(*) >= ALL(
        SELECT COUNT(*)
        FROM account a
        GROUP BY a.branch_name
    );
--c)
SELECT a.branch_name,
    AVG(a.balance)
FROM account a
GROUP BY a.branch_name
HAVING AVG(a.balance) >= ALL(
        SELECT AVG(a.balance)
        FROM account a
        GROUP BY a.branch_name
    );
--d)
SELECT COUNT(DISTINCT customer_name),
    b.branch_city
FROM branch b
    LEFT OUTER JOIN customer c ON c.customer_city = b.branch_city
GROUP BY b.branch_city;
--e)
SELECT COUNT(DISTINCT c.customer_name),
    b.branch_city
FROM branch b
    LEFT OUTER JOIN customer c ON c.customer_city = b.branch_city
GROUP BY b.branch_city
HAVING COUNT(DISTINCT c.customer_name) >= ALL(
        SELECT COUNT(DISTINCT c.customer_name)
        FROM branch b
            LEFT OUTER JOIN customer c ON c.customer_city = b.branch_city
        GROUP BY b.branch_city
    );
--f)
SELECT c.customer_name,
    c.customer_street,
    c.customer_city,
    SUM(a.balance)
FROM customer c
    INNER JOIN depositor d ON d.customer_name = c.customer_name
    INNER JOIN account a ON d.account_number = a.account_number
GROUP BY c.customer_name
HAVING SUM(a.balance) >= ALL(
        SELECT SUM(a.balance)
        FROM depositor d
            INNER JOIN account a ON d.account_number = a.account_number
        GROUP BY d.customer_name
    );
--Question 6
--a)
SELECT a.account_number
FROM account a
WHERE 1 = (
        SELECT COUNT(d.account_number)
        FROM account as acc
            RIGHT OUTER JOIN depositor d ON d.account_number = acc.account_number
        WHERE d.account_number = a.account_number
        GROUP BY acc.account_number
    );
--b)Don't undertand if it's city with customer and branch or just branch
--If just branch just select branch_city from branch
SELECT DISTINCT c.customer_city
FROM customer c
WHERE EXISTS(
        SELECT b.branch_city
        FROM branch b
        WHERE b.branch_city = c.customer_city
    );
--c)
SELECT DISTINCT b.branch_city
FROM branch b
WHERE EXISTS(
        SELECT COUNT(*)
        FROM branch br
            INNER JOIN account a ON a.branch_name = br.branch_name
        WHERE br.branch_city = b.branch_city
        GROUP BY branch_city
        HAVING COUNT(*) >= 2
    );
--d)
SELECT DISTINCT b.branch_name
FROM branch b
WHERE EXISTS(
        SELECT COUNT(*)
        FROM depositor d
            INNER JOIN account a ON d.account_number = a.account_number
        WHERE b.branch_name = a.branch_name
        GROUP BY a.account_number
        HAVING COUNT(*) >= 2
    );
-- Question 7
--a)
SELECT c.customer_name,
    c.customer_street,
    b.loan_number
FROM customer c
    LEFT OUTER JOIN borrower b ON b.customer_name = c.customer_name
WHERE c.customer_city = 'Lisbon';

-- Question 8
-- a) accounts on all branches
SELECT DISTINCT dep.customer_name
FROM depositor dep
WHERE NOT EXISTS(
        SELECT branch_name
        FROM branch
        EXCEPT
        SELECT branch_name
        FROM depositor AS d
            JOIN account a ON d.account_number = a.account_number
        WHERE d.customer_name = dep.customer_name
    );
--b)
SELECT DISTINCT dep.customer_name
FROM depositor dep
WHERE NOT EXISTS(
        SELECT branch_name
        FROM branch
        WHERE branch_city = 'Lisbon'
        EXCEPT
        SELECT branch_name
        FROM depositor d
            JOIN account a ON d.account_number = a.account_number
        WHERE d.customer_name = dep.customer_name
    );
--c)
SELECT DISTINCT c.customer_name
FROM depositor dep
    JOIN customer c ON dep.customer_name = c.customer_name
WHERE NOT EXISTS(
        SELECT branch_name
        FROM branch
        WHERE branch_city = c.customer_city
        EXCEPT
        SELECT branch_name
        FROM depositor d
            JOIN account a ON d.account_number = a.account_number
        WHERE d.customer_name = c.customer_name
    );
-- What are the branches that have loans for all the clients?
SELECT DISTINCT br.branch_name
FROM branch br
WHERE NOT EXISTS(
        SELECT c.customer_name
        FROM customer c
        EXCEPT
        SELECT bo.customer_name
        FROM loan l
            INNER JOIN borrower bo ON bo.loan_number = l.loan_number
        WHERE l.branch_name = br.branch_name
    );


    SELECT *
    FROM branch b
    INNER JOIN (
        SELECT branch_name,
            SUM(balance) as total_assets
        FROM account
        GROUP BY branch_name
    ) a ON a.branch_name = b.branch_name
    INNER JOIN (
        SELECT branch_name,
            SUM(amount) as total_liabilities
        FROM loan
        GROUP BY branch_name
    ) l ON l.branch_name = b.branch_name;

SELECT nome, vinho 
FROM vinho v NATURAL JOIN pertence p NATURAL JOIN produtor pr
WHERE pr.region = 'Douro' 
      AND v.teor_alcoolico >= ALL( SELECT teor_alcoolico 
                                   FROM vinho v1 NATURAL JOIN pertence p1 NATURAL JOIN produtor pr1
                                   WHERE pr1.regiao = 'Douro')