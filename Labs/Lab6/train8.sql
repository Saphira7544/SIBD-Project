--a)
drop function if exists absolut_net(varchar);
create or replace function absolut_net(nameC varchar(80)) returns numeric as
$$
declare
    net numeric;
begin
    select coalesce((select sum(a.balance)
                     from account a
                              inner join depositor d on a.account_number = d.account_number
                     where d.customer_name = nameC), 0) - COALESCE(
                   (
                       SELECT SUM(l.amount)
                       FROM loan l
                                INNER JOIN borrower b ON b.loan_number = l.loan_number
                       WHERE b.customer_name = nameC
                   ),
                   0
               )
    into net;
    return net;
end;
$$ language plpgsql;

-- with ifs
create or replace function absolut_net(nameC varchar(80)) returns numeric as
$$
declare
    net      numeric;
    balances numeric;
    amounts  numeric;
begin
    select sum(a.balance)
    from account a
             inner join depositor d on a.account_number = d.account_number
    where d.customer_name = nameC
    into balances;
    if balances is null then
        balances := 0;
    end if;
    SELECT SUM(l.amount)
    FROM loan l
             INNER JOIN borrower b ON b.loan_number = l.loan_number
    WHERE b.customer_name = nameC
    into amounts;
    if amounts is null then
        amounts := 0;
    end if;
    net := balances - amounts;
    return net;
end;
$$ language plpgsql;

select absolut_net(c.customer_name), c.customer_name
from customer c;

--b)
create or replace function avg_diff(b1 varchar(80), b2 varchar(80)) returns numeric as
$$
declare
    diff numeric;
    avg1 numeric;
    avg2 numeric;
begin
    select avg(a.balance) from account a where a.branch_name = b1 into avg1;
    if avg1 is null then
        avg1 := 0;
    end if;
    select avg(a.balance) from account a where a.branch_name = b2 into avg2;
    if avg2 is null then
        avg2 := 0;
    end if;
    diff := avg1 - avg2;
    return diff;
end;
$$ language plpgsql;

select avg_diff('Bolsa', 'Uptown');

--Help query
select avg(a.balance), a.branch_name
from account a
group by branch_name;


-- c)

select max(avg_diff(b1.branch_name, b2.branch_name)), b1.branch_name
from branch b1,
     branch b2
group by b1.branch_name
having max(avg_diff(b1.branch_name, b2.branch_name)) >=
    all (select max(avg_diff(b1.branch_name, b2.branch_name))
         from branch b1,
              branch b2
         group by b1.branch_name);

-- d)
alter table depositor
    drop constraint fk_depositor_account;

alter table depositor
    add constraint fk_depositor_account
        foreign key (account_number) references account (account_number) on delete cascade;

-- now it deletes the entry from depositor as well
delete
from account
where account_number = 'A-101';

-- e)
alter table
    borrower
    drop constraint fk_borrower_loan;

alter table borrower
    add
        constraint fk_borrower_loan foreign key (loan_number) references loan (loan_number) on
            delete cascade;

delete
from loan
where loan_number = 'L-17';

-- tests
alter table account
    drop constraint fk_account_branch;

alter table loan
    drop constraint fk_loan_branch;
alter table account
    add constraint fk_account_branch foreign key (branch_name) references branch (branch_name) on delete cascade;
delete
from branch
where branch_name = 'Downtown';


-- Triggers

-- a)

update loan
set amount = -450
where loan_number = 'L-17';

drop function pay_loan cascade;

create or replace function pay_loan() returns trigger as
$$
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


create trigger update_loan
    after update
    on loan
    for each row
execute procedure pay_loan();

update loan
set amount = -900
where loan_number = 'L-23';

-- b)
drop function prev_loan cascade;

create or replace function prev_loan() returns trigger as
$$
begin
    if new.customer_name not in (select d.customer_name
                                 from account a
                                          inner join depositor d on a.account_number = d.account_number)
    then
        raise exception 'Customer without account %', new.customer_name
            using hint = 'Check is customer has account';
    end if;
    return new;

end ;
$$ language plpgsql;

create trigger prevent_loan
    before insert
    on borrower
    for each row
execute procedure prev_loan();

insert into borrower values ('Gonzalez','L-57');

