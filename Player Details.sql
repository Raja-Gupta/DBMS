create database sql2_project;
use sql2_project;

# 1. Import the csv file to a table in the database.

/* Table icc_bat imported via table data import wizard*/
select * from icc_bat;

# 2.	Remove the column 'Player Profile' from the table.

alter table icc_bat drop column `Player Profile` ;

# 3.	Extract the country name and player names from the given data and store it in seperate columns for further usage.

select *,substring_index(player,'(',1) playername,trim(trailing  ')' from substring_index(player,'(',-1)) country_name 
from icc_bat;

alter table icc_bat add column playername varchar(30) generated always as (substring_index(player,'(',1)) stored;
alter table icc_bat add column country_name varchar(30) generated always as (trim(trailing  ')' from substring_index(player,'(',-1))) stored;
select * from icc_bat;

# 4.	From the column 'Span' extract the start_year and end_year and store them in seperate columns for further usage.

alter table icc_bat add column start_year int GENERATED ALWAYS as (substring_index(span,'-',1)) stored, 
add column end_year int GENERATED ALWAYS as (substring_index(span,'-',-1)) stored; 
select * from icc_bat;

# 5.	The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player had 
# completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.

select *,(case when hs like '%*' then hs end ) notout_score ,
(case when hs not like '%*' then hs end ) highest_score
from icc_bat
order by cast(hs as unsigned) desc;

# 6.	Using the data given, considering the players who were active in the year of 2019, 
# create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for India.

with t as (select *, dense_rank() over(order by `avg` desc) rnk 
from icc_bat
where start_year<=2019 and end_year >= 2019 and country_name like '%India%') 
select * 
from t
where rnk between 1 and 6;

# 7.	Using the data given, considering the players who were active in the year of 2019, 
# create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for India.

with t as (select *, dense_rank() over(order by `100` desc) rnk 
from icc_bat
where start_year<=2019 and end_year >= 2019 and country_name like '%India%') 
select * 
from t
where rnk between 1 and 6;

# 8.	Using the data given, considering the players who were active in the year of 2019, 
# create a set of batting order of best 6 players using 2 selection criterias of your own for India.

with t as (select *, dense_rank() over(order by runs desc,`avg` desc) rnk 
from icc_bat
where start_year<=2019 and end_year >= 2019 and country_name like '%India%' and mat > 10 and runs > 2000) 
select * 
from t
where rnk between 1 and 6;

# 9. Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the year of 2019, 
# create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for South Africa.

create  view Batting_Order_GoodAvgScorers_SA as (select * from (select *, dense_rank() over(order by `avg` desc) rnk 
from icc_bat
where (start_year <= 2019) and (end_year >= 2019) and (country_name = 'ICC/SA' or country_name = 'sa')) t where rnk between 1 and 6);

select *  from Batting_Order_GoodAvgScorers_SA;

# 10. Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active in the year of 2019, 
# create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for South Africa.

create  view Batting_Order_HighestCenturyScorers_SA as (select * from (select *, dense_rank() over(order by `100` desc) rnk 
from icc_bat
where (start_year <= 2019) and (end_year >= 2019) and (country_name = 'ICC/SA' or country_name = 'sa')) t where rnk between 1 and 6);

select *  from Batting_Order_HighestCenturyScorers_SA;
