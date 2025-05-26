--a)
SELECT distinct c.customer_name
FROM customer c
         inner join branch b on b.branch_city = c.customer_city;

SELECT DISTINCT customer_name
FROM customer
WHERE customer_city IN (
    SELECT branch_city
    FROM branch
);
--b)
select distinct c.customer_name, c.customer_street
from customer c
where c.customer_name IN (select d.customer_name
                          from depositor d)
  and c.customer_name not IN (select b.customer_name
                              from borrower b);
--c)
select c.customer_name
from customer c
         inner join borrower b on c.customer_name = b.customer_name
         inner join loan l on l.loan_number = b.loan_number
         inner join branch b2 on b2.branch_name = l.branch_name
where branch_city = customer_city;

--d)
select distinct c.customer_name
from customer c
where c.customer_name IN (select d.customer_name
                          from depositor d)
  and c.customer_name IN (select b.customer_name
                          from borrower b);

--2

--a)
select sum(a.balance)
from account a
         inner join branch b on b.branch_name = a.branch_name
where b.branch_city = 'Amadora';

--b)
select max(a.balance)
from account a
         inner join branch b on b.branch_name = a.branch_name
where b.branch_city = 'Amadora';

--c)
select count(distinct c.customer_name)
from customer c
         inner join depositor d on c.customer_name = d.customer_name
         inner join account a on a.account_number = d.account_number
         inner join branch b2 on b2.branch_name = a.branch_name
where branch_city = customer_city;
--d)
select count(distinct c.customer_name) as num
from customer c
where c.customer_name IN (select d.customer_name
                          from depositor d)
  and c.customer_name not IN (select b.customer_name
                              from borrower b);
-- 3
--a)
select max(a.balance) as maximum_balance, b.branch_city
from account a
         inner join branch b on b.branch_name = a.branch_name
group by b.branch_city;
-- b)
select avg(a.balance) as maximum_balance, b.branch_city
from account a
         inner join branch b on b.branch_name = a.branch_name
group by b.branch_city;

--c)
select count(a.account_number), b.branch_name, b.branch_city
from account a
         right outer join branch b on b.branch_name = a.branch_name
group by b.branch_name;

--d)
select count(a.account_number), b.branch_city
from account a
         right outer join branch b on b.branch_name = a.branch_name
group by b.branch_city;

--e)
select sum(coalesce(a.balance, 0)), c.customer_name
from account a
         inner join depositor d on a.account_number = d.account_number
         right join customer c on c.customer_name = d.customer_name
group by c.customer_name;

-- f)
select count(b.customer_name) as n_loan, b.customer_name
from borrower b
group by b.customer_name
having count(b.customer_name) > 1;

--e)
select count(d.customer_name), d.customer_name
from depositor d
group by d.customer_name
--comment condition having to observe order
having count(d.customer_name) > 2
order by d.customer_name asc;

--4

--a)
select b.branch_name
from branch b
where assets < (select sum(l.amount)
                from loan l
                where b.branch_name = l.branch_name);
/*
select b.branch_name, b.assets
from branch b

select sum(l.amount), l.branch_name
from loan l
group by l.branch_name
 */

--b)
-- Help query to check every value
select b.branch_name,
       (select sum(a.balance)
        from account a
        where a.branch_name = b.branch_name) as real_assets,
       (select sum(l.amount)
        from loan l
        where b.branch_name = l.branch_name) as liabilities
from branch b;
-- Doesn't work properly due to nulls (in the case of < it doesn't matter but with > fails)
select b.branch_name,
       (select sum(a.balance)
        from account a
        where a.branch_name = b.branch_name) as real_assets,
       (select sum(l.amount)
        from loan l
        where b.branch_name = l.branch_name) as liabilities
from branch b
where (select sum(a.balance)
       from account a
       where a.branch_name = b.branch_name) < (
          select sum(l.amount)
          from loan l
          where b.branch_name = l.branch_name);
-- Treats nulls as zeros
select b.branch_name,
       coalesce((select sum(a.balance)
                 from account a
                 where a.branch_name = b.branch_name), 0) as real_assets,
       coalesce((select sum(l.amount)
                 from loan l
                 where b.branch_name = l.branch_name), 0) as liabilities
from branch b
where coalesce((select sum(a.balance)
                from account a
                where a.branch_name = b.branch_name), 0) < coalesce((select sum(l.amount)
                                                                     from loan l
                                                                     where b.branch_name = l.branch_name), 0);
-- c)

select b.branch_name,
       coalesce((select sum(a.balance)
                 from account a
                 where a.branch_name = b.branch_name), 0) -
       coalesce((select sum(l.amount)
                 from loan l
                 where b.branch_name = l.branch_name), 0) as difference
from branch b;

--d)
select c.customer_name,
       coalesce((select sum(a.balance)
                 from account a
                          inner join depositor d on a.account_number = d.account_number
                 where d.customer_name = c.customer_name), 0) as total_balance,
       coalesce((select sum(l.amount)
                 from loan l
                          inner join borrower b on l.loan_number = b.loan_number
                 where b.customer_name = c.customer_name), 0) as total_loans
from customer c;

--e)
select c.customer_name
from customer c
where coalesce((select sum(a.balance)
                from account a
                         inner join depositor d on a.account_number = d.account_number
                where d.customer_name = c.customer_name), 0) <
      coalesce((select sum(l.amount)
                from loan l
                         inner join borrower b on l.loan_number = b.loan_number
                where b.customer_name = c.customer_name), 0);

--5

--a)
select b.customer_name
from borrower b
         inner join loan l on b.loan_number = l.loan_number
group by b.customer_name
having sum(l.amount) >= ALL (select sum(l.amount)
                             from borrower b
                                      inner join loan l on b.loan_number = l.loan_number
                             group by b.customer_name);


--Help query
select *
from branch b
         left outer join account a on b.branch_name = a.branch_name;


-- b)
select a.branch_name
from account a
group by a.branch_name
having count(a.account_number) >= ALL (select count(a2.account_number)
                                       from account a2
                                       group by a2.branch_name);


-- c)
select branch_name
from account
group by branch_name
having avg(balance) >= ALL (select avg(a.balance)
                            from account a
                            group by a.branch_name);

-- help query
select *
from branch b
         left outer join customer c on c.customer_city = b.branch_city;

-- d)
select count(distinct c.customer_name), b.branch_city
from branch b
         left outer join customer c on c.customer_city = b.branch_city
group by b.branch_city;

-- e)
select b.branch_city
from branch b
         left outer join customer c on c.customer_city = b.branch_city
group by b.branch_city
having count(distinct c.customer_name) >= ALL (select count(distinct c.customer_name)
                                               from branch b
                                                        left outer join customer c on c.customer_city = b.branch_city
                                               group by b.branch_city);

--f)
select c.customer_name
     , c.customer_city
     , c.customer_street
     , sum(a.balance)
from customer c
         inner join depositor d on c.customer_name = d.customer_name
         inner join account a on a.account_number = d.account_number
group by c.customer_name
having sum(a.balance) >= ALL (select sum(a2.balance)
                              from customer c2
                                       inner join depositor d2 on c2.customer_name = d2.customer_name
                                       inner join account a2 on a2.account_number = d2.account_number
                              group by c2.customer_name);

-- 6

--a)
select a.account_number
from account a
where (select count(*)
       from depositor d
       where d.account_number = a.account_number) = 1;

--b)
select branch_city
from branch;

--c)
select distinct b.branch_city
from branch b
where exists(select count(*)
             from account a
                      inner join branch b2 on a.branch_name = b2.branch_name
             where b2.branch_name = b.branch_name
             having count(*) > 1);

select b.branch_city
from account a
         inner join branch b on a.branch_name = b.branch_name
group by b.branch_city
having count(*) > 1;

-- d)
select b.branch_name
from branch b
where exists(select count(*)
             from account a
                      inner join depositor d on a.account_number = d.account_number
             where a.branch_name = b.branch_name
             group by a.account_number
             having count(*) > 1);

-- 7

--a)

select c.customer_name, c.customer_street, b.loan_number
from customer c
         left outer join borrower b on c.customer_name = b.customer_name
where c.customer_city = 'Lisbon';

--b)

select c.customer_name,
       c.customer_city,
       (select max(a.balance)
        from account a
                 inner join depositor d on a.account_number = d.account_number
        where d.customer_name = c.customer_name) as biggest_balance,
       (select max(l.amount)
        from loan l
                 inner join borrower b on l.loan_number = b.loan_number
        where b.customer_name = c.customer_name) as biggest_amount
from customer c;

select c.customer_name,
       c.customer_city,
       max(ca.balance),
       max(cb.amount)
from customer c
         left outer join (borrower b inner join loan l on b.loan_number = l.loan_number) as cb
                         on c.customer_name = cb.customer_name
         left outer join (account a inner join depositor d on a.account_number = d.account_number) as ca
                         on c.customer_name = ca.customer_name
group by c.customer_name;



-- 8
-- a)
select c.customer_name
from customer c
where not exists(select b.branch_name -- selects all branches
                 from branch b
                     except
                 select b2.branch_name -- takes from all branches the branches where customer has account
                 from branch b2
                          inner join account a on b2.branch_name = a.branch_name
                          inner join depositor d on a.account_number = d.account_number
                 where d.customer_name = c.customer_name);
--b)
select c.customer_name
from customer c
where not exists(select b.branch_name
                 from branch b
                 where b.branch_city = 'Lisbon'
                     except
                 select a.branch_name
                 from account a
                          inner join depositor d on a.account_number = d.account_number
                 where d.customer_name = c.customer_name);
-- c)
select distinct c.customer_name
from customer c
         inner join depositor d on c.customer_name = d.customer_name
where not exists(select b.branch_name
                 from branch b
                 where b.branch_city = c.customer_city
                     except
                 select branch_name
                 from account a
                          inner join depositor d2 on a.account_number = d2.account_number
                 where d2.customer_name = c.customer_name);

-- What are the branches that have loans for all the clients?
select b.branch_name
from branch b
where not exists(select c.customer_name
                 from customer c
                     except
                 select bo.customer_name
                 from borrower bo
                          inner join loan l on bo.loan_number = l.loan_number
                 where l.branch_name = b.branch_name);


-- Test Queries

select * --customer.customer_name
from customer
         inner join depositor on customer.customer_name = depositor.customer_name;

select b.branch_name
from branch b
where not exists(select branch_name
                 from branch b
                     except
                 select bo.customer_name
                 from borrower bo
                          inner join loan l on bo.loan_number = l.loan_number
                 where l.branch_name = b.branch_name);

/*
select d + Interval '10 y 1 h 10 m 10 s'
from customer
where customer_name='Parker';
*/

update loan
set amount = amount + 300
where amount = 1300;

delete
from account
where account_number = 'xxx';



select d.branch_name, avg(d.balance)
from (select branch_name, sum(balance) as balance
      from account
      group by branch_name) as d
group by branch_name;
