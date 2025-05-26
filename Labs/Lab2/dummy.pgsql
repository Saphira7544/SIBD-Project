/*"(a)"*/
select distinct customer_name
from customer
where customer_city = 'Lisbon';
/*"(b)"*/
select distinct account_number
from account
where balance > 500;
/*"(c)"*/
select distinct balance* 1.277 as new_balance
from account
where branch_name = 'Downtown'
;
/*"(e)"*/
select distinct customer_city
from customer natural join borrower natural join loan 
where amount between 1000 and 2000 
;
/*"(f)"*/
select balance
from account natural join depositor  natural join borrower
where loan_number = 'L-15';
/*"(g)"*/
select branch_name
from account natural join depositor
where customer_name like 'J%n';

/* '%' any number of characters in between
   '_' one character */

/*"(h)"*/
select amount
from loan natural join borrower natural join customer
where customer_city like '______';
/*"(i)"*/
select amount
from loan natural join borrower natural join customer
where customer_city like '_%_%';
/*"(j)"*/
select branch_name, assets
from branch natural join account natural join depositor
where customer_name = 'Johnson';
/*"(k)"*/
select customer_name
from customer natural join borrower natural join loan natural join branch
where branch_city = customer_city;
/*"(l)"*/
select distinct customer_name
from customer
where customer_name in (select branch_city from branch);
/*"(test)"*/
select distinct customer_name, customer_city
from customer INNER JOIN branch on branch_city= customer_city
where customer_name = 'Brown' or customer_name = 'Cook' or customer_name = 'Gonzalez';

/*"(m)"*/
select customer_name
from depositor
intersect
select  customer_name
from borrower;

select distinct customer_name
from depositor natural join borrower
;

/*"(n)"*/
select distinct customer_name
from customer
where customer_city not in (select branch_city from branch)
;

/*"(o)"*/
select SUM(balance)
from account natural join branch
where branch_city = 'Lisbon'
;