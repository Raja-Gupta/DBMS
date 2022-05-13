use ipl;
-- 1
select bd.bidder_id,ibd.bidder_name,ibp.no_of_bids as total_bid,sum(bd.bid_status='won') as win,
((sum(bd.bid_status='won'))/(ibp.no_of_bids))*100 as win_percent
from ipl_bidding_details as bd
join ipl_bidder_points as ibp on bd.bidder_id= ibp.bidder_id
join ipl_bidder_details as ibd on bd.bidder_id= ibd.bidder_id
group by ibd.bidder_id
order by win_percent desc;

-- 2
select a.bid_team,a.team_name,a.No_of_bids from
(select ibd.bid_team,t.team_name,count(ibd.bid_team ) as 'No_of_bids',(rank() over (order by count(ibd.bid_team )desc)) as "team"
from ipl_bidding_details as ibd inner join ipl_match_schedule as ims
on ibd.schedule_id=ims.schedule_id
inner join ipl_match as m
on m.match_id=ims.match_id
inner join ipl_team as t
on ibd.bid_team=t.team_id
group by ibd.bid_team order by count(ibd.bid_team) desc)a 
where a.team =1
union
select a.bid_team,a.team_name,a.No_of_bids from
(select ibd.bid_team,t.team_name,count(ibd.bid_team ) as 'No_of_bids',(rank() over (order by count(ibd.bid_team ))) as "team"
from ipl_bidding_details as ibd inner join ipl_match_schedule as ims
on ibd.schedule_id=ims.schedule_id
inner join ipl_match as m
on m.match_id=ims.match_id
inner join ipl_team as t
on ibd.bid_team=t.team_id
group by ibd.bid_team order by count(ibd.bid_team) desc)a 
where a.team in (1);

-- 3
select a.stadium_id,a.stadium_name ,a.wins,count(ms.stadium_id) as no_of_match,(wins/count(ms.stadium_id))*100 as "Win_Percent" 
from (select m.match_id,s.stadium_id,s.stadium_name,count(s.stadium_id) as "wins"
from ipl_stadium as s inner join ipl_match_schedule as ms
on s.stadium_id=ms.stadium_id
inner join ipl_match as m
on m.match_id=ms.match_id
where m.toss_winner=m.match_winner group by s.stadium_id)a 
inner join  ipl_match_schedule as ms
on a.stadium_id=ms.stadium_id
group by ms.stadium_id 
order by win_percent desc;

-- 4
select a.team_id,t.team_name,a.won,count(ibd.bid_team) as bids from
(select its.team_id,sum(its.matches_won) as won from ipl_team_standings as its 
group  by team_id order by won desc)a inner join ipl_bidding_details as ibd
on ibd.bid_team =a.team_id
inner join ipl_team as t
on a.team_id=t.team_id
group by ibd.bid_team
order by a.won desc,count(ibd.bid_team)
limit 1;

-- 5
select its.team_id,t.team_name, its.total_points as 'present_year_point',lag(its.total_points,1) over (partition by its.team_id order by its.tournmt_id) as prev_year_points, 
((its.total_points-(lag(its.total_points,1) over (partition by its.team_id order by its.tournmt_id)))/(lag(its.total_points,1) over (partition by its.team_id order by its.tournmt_id)))*100 as 'win%' 
from ipl_team_standings as its inner join ipl_team as t
on its.team_id=t.team_id
order by ((its.total_points-(lag(its.total_points,1) over (partition by its.team_id order by its.tournmt_id)))/(lag(its.total_points,1) over (partition by its.team_id order by its.tournmt_id)))*100 desc 
limit 1;