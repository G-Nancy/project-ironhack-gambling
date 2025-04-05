use ih_gambling;

-- Question 01: Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers.
select Title, FirstName, LastName, DateOfBirth
from customer;

-- Question 02: Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). I can see by visual inspection that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this?
select CustomerGroup, count(distinct CustId)
from customer
group by CustomerGroup;

-- Question 03: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table.
select distinct customer.*, account.CurrencyCode
from customer
left outer join account
on customer.CustId = account.CustId;


-- Question 04: Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. Please note that the transactions are stored in the betting table and there is a product code in that table that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report.
select product.CLASSID,product.CATEGORYID,product.product,product.description, betting.BetDate, sum(betting.Bet_Amt) as total_amt
from betting
inner join product
on betting.ClassId= product.CLASSID and betting.CategoryId = product.CATEGORYID
group by product.CLASSID,product.CATEGORYID,product.product,product.description, betting.BetDate
order by betting.BetDate desc
;

-- Question 05: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions.
select product.CLASSID,product.CATEGORYID,product.product,product.description, betting.BetDate, sum(betting.Bet_Amt) as total_amt
from betting
inner join product
on betting.ClassId= product.CLASSID and betting.CategoryId = product.CATEGORYID
where betting.BetDate >= '01/11/2012' and betting.Product='Sportsbook'
group by product.CLASSID,product.CATEGORYID,product.product,product.description, betting.BetDate
order by betting.BetDate asc
;

-- Question 06: As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December.
select account.CurrencyCode, customer.CustomerGroup, sum(betting.Bet_Amt) as total_amt
from betting
left join product
on betting.ClassId= product.CLASSID and betting.CategoryId = product.CATEGORYID
inner join account
on betting.AccountNo = account.AccountNo
inner join customer
on account.CustId = customer.CustId
where betting.BetDate >= '01/12/2012'
group by account.CurrencyCode, customer.CustomerGroup
;

select *
from betting 
where AccountNo is null or  Product is null;

select min(BetDate), max(BetDate)
from betting 
order by BetDate desc;


-- Question 07: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November.
select Title, FirstName, LastName, bett.amount
from customer
inner join account
on customer.CustId = account.CustId
left outer join 
	(select AccountNo, sum(Bet_Amt) as amount
	from betting
	where month(str_to_date(BetDate,'%d/%m/%Y')) = 11
	group by betting.AccountNo) as bett
on account.AccountNo = bett.AccountNo
;

select AccountNo, sum(Bet_Amt)
from betting
where month(str_to_date(BetDate,'%d/%m/%Y')) = 11
group by betting.AccountNo;


-- Question 08: Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas.
select AccountNo, count(distinct concat(ClassId,CategoryId)) as prds
from betting
group by betting.AccountNo
having prds > 1
;

select distinct AccountNo 
from betting
where product = 'Vegas'
union
select distinct AccountNo 
from betting
where product = 'Sportsbook'
;

-- Question 09: Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products.
select Title, FirstName, LastName, bett.amount
from customer
inner join account
on customer.CustId = account.CustId
left outer join 
	(select AccountNo, sum(Bet_Amt) as amount, count(distinct concat(ClassId,CategoryId)) as prds
	from betting
    where product = 'Sportsbook' 
	group by betting.AccountNo
    having prds = 1) as bett
on account.AccountNo = bett.AccountNo
;
-- what is "bets for both products" if condiiton is "players who only play one product"?????

-- Question 10: The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked.
select AccountNo, ClassId,CategoryId, Product, amt
 from (
select 
betting.AccountNo, ClassId,CategoryId, Product
, sum(Bet_Amt) as amt
, row_number() over (partition by betting.AccountNo order by sum(Bet_Amt) desc, concat(ClassId,CategoryId) ) as rn
from betting
group by betting.AccountNo, ClassId,CategoryId, Product
) as a
where rn = 1
order by AccountNo,amt desc;

use ih_gambling;
select * from betting
order by accountNo desc
limit 100;

select * from betting
where AccountNo = '01196ZZ   ' or `AccountNo_[0]` = '01196ZZ   ' or `AccountNo_[1]`='01196ZZ   '
order by accountNo desc;

select * from product 
where 
-- bet_or_play = 0
product = 'Vegas'
limit 100;

select AccountNo, Product, sum(Bet_Amt)
 from betting
where AccountNo = '01196ZZ   ' -- or `AccountNo_[0]` = '01196ZZ   ' or `AccountNo_[1]`='01196ZZ   '
group by AccountNo, Product
order by accountNo desc; -- 89960.70000000001, 43708

select * 
from betting;

select * from (
select `AccountNo_[0]`, count(distinct AccountNo),count(distinct concat(ClassId,CategoryId)) as prds, sum(Bet_Amt) as sum, 'shared' as flag
from betting
where `AccountNo_[0]`!=AccountNo
group by `AccountNo_[0]`
union
select `AccountNo_[0]`, count(distinct AccountNo), count(distinct concat(ClassId,CategoryId)) as prds, sum(Bet_Amt) as sum, 'individual' as flag
from betting
where `AccountNo_[0]`=AccountNo
group by `AccountNo_[0]`
) x 
order by `AccountNo_[0]` , sum asc;