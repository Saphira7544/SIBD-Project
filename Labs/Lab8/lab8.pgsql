CREATE or REPLACE FUNCTION absolute_net(name_C VARCHAR(80)) RETURNS NUMERIC AS $$
DECLARE abs_net NUMERIC;
BEGIN
SELECT COALESCE(
        (
            SELECT SUM(a.balance)
            FROM account a
                INNER JOIN depositor d ON d.account_number = a.account_number
            WHERE d.customer_name = name_C
        ),
        0
    ) - COALESCE(
        (
            SELECT SUM(l.amount)
            FROM loan l
                INNER JOIN borrower b ON b.loan_number = l.loan_number
            WHERE b.customer_name = name_C
        ),
        0
    ) INTO abs_net;
RETURN abs_net;
END;
$$ LANGUAGE plpgsql;

--Query

SELECT absolute_net(customer_name),
       customer_name
FROM customer;

--IFS

CREATE or REPLACE FUNCTION absolute_net2(name_C VARCHAR(80)) RETURNS NUMERIC AS $$
DECLARE amounts NUMERIC;
DECLARE balances NUMERIC;
BEGIN
SELECT SUM(a.balance) INTO balances
FROM account a
    INNER JOIN depositor d ON d.account_number = a.account_number
WHERE d.customer_name = name_C;
IF balances IS NULL THEN balances := 0;
END IF;
SELECT SUM(l.amount) INTO amounts
FROM loan l
    INNER JOIN borrower b ON b.loan_number = l.loan_number
WHERE b.customer_name = name_C;
IF amounts IS NULL THEN amounts := 0;
END IF;
RETURN balances - amounts;
END;
$$ LANGUAGE plpgsql;

--Query2

SELECT absolute_net2(customer_name),
       customer_name
FROM customer;

--b)

CREATE OR REPLACE FUNCTION diff_avg(b1 varchar(80), b2 varchar(80)) RETURNS NUMERIC AS $$
DECLARE b1_avg NUMERIC;
DECLARE b2_avg NUMERIC;
BEGIN
SELECT avg(balance) INTO b1_avg
FROM account
WHERE branch_name = b1;
IF b1_avg IS NULL THEN b1_avg := 0;
END IF;
SELECT avg(balance) INTO b2_avg
FROM account
WHERE branch_name = b2;
IF b2_avg IS NULL THEN b2_avg := 0;
END IF;
RETURN b1_avg - b2_avg;
END;
$$ LANGUAGE plpgsql;

--c)

select b1.branch_name,
       max(diff_avg(b1.branch_name, b2.branch_name))
from branch b1,
     branch b2
group by b1.branch_name
having max(diff_avg(b1.branch_name, b2.branch_name)) =
    ( select max(diff_avg(b3.branch_name, b4.branch_name))
     from branch b3,
          branch b4);

--altc)

select b1.branch_name,
       max(diff_avg(b1.branch_name, b2.branch_name))
from branch b1,
     branch b2
group by b1.branch_name
having max(diff_avg(b1.branch_name, b2.branch_name)) =
    ( select max(diff_avg(b1.branch_name, b2.branch_name))
     from branch b1,
          branch b2 );

--d)

ALTER TABLE depositor
DROP CONSTRAINT fk_depositor_account; -- drop current constraint

ALTER TABLE depositor ADD CONSTRAINT fk_depositor_account
FOREIGN KEY(account_number) REFERENCES account(account_number) ON
DELETE CASCADE; -- Remake CONSTRAINT

--TRIGGER

DROP TRIGGER IF EXISTS update_loan_trigger on loan;


create or replace function update_loan() returns trigger as $$
begin

    if new.amount <= 0 then
      update branch
      set assets = assets - new.amount
      where branch_name = new.branch_name;

      delete from borrower where loan_number = new.loan_number;
      delete from loan where loan_number = new.loan_number;
    end if;

    return new;

end;
$$ language plpgsql;

create TRIGGER update_loan_trigger after
update on loan
for each row execute procedure update_loan();

--Exceptions

create or replace function verify_account() returns trigger as $$
begin
  if new.customer_name not in (select customer_name from depositor) then
      raise exception 'O Cliente % NÃO tem conta neste banco.', new.customer_name;
  end if;

  return new;
end;
$$ language plpgsql;

