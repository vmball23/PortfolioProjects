select *
from yankeespitchingstats y;

select *
from lastpitchyankees l;

--Question 1 AVG Pitches Per at Bat Analysis

--1a avg pitches per at bat (lastpitchyankees)

select avg(pitch_number) as AvgNumPitchesPerAtBat
from lastpitchyankees l;

--1b avg pitches per at bat Home vs Away (lastpitchyankees) --> Union

select  'Home' as TypeOfGame, avg(pitch_number * 1.0) as AvgNumPitchesPerAtBat
from lastpitchyankees l
where home_team = 'NYY'
union 
select  'Away' as TypeOfGame, avg(pitch_number * 1.0) as AvgNumPitchesPerAtBat
from lastpitchyankees l
where away_team = 'NYY';

--1c avg pitches per at bat Lefty vs Righty --> Case Statement

select  avg(case when batter_hand = 'L' then pitch_number * 1.0 end) as LeftyAtBats,
		avg(case when batter_hand = 'R' then pitch_number * 1.0 end) as RightyAtBats
from lastpitchyankees l;

--1d avg pitcher per at bat Lefty vs Righty | each away game --> Partition By

select distinct home_team, pitcher_hand, avg(1.0 * pitch_number) over (partition by home_team, pitcher_hand)
from lastpitchyankees l
where away_team = 'NYY';

--1e avg pitches per at bat per pitcher with 20+ innings | descending order (lastpitchyankees + yankeespitchingstats)

select yps."name", avg(pitch_number * 1.0) as AvgPitches
from lastpitchyankees lpy
join yankeespitchingstats yps
on yps.pitcher_id = lpy.pitcher
where ip >= 20
group by 1
order by 2 desc;

--Question 2 Last Pitch Analysis

--2a count of the last pitches thrown, desc order (lastpitchyankees)

select pitch_name, count(1)
from lastpitchyankees l 
group by 1
order by 2 desc;

--2b count of the different last pitches Fastball or Offspeed (lastpitchyankees)

select sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) as Fastball,
	   sum(case when pitch_name not in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) as Offspeed
from lastpitchyankees l;

--2c percentage of the different last pitches Fastball or Offspeed (lastpitchyankees)

select 100.0 * sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end)/count(1) as Fastball_Percentage,
	   100.0 * sum(case when pitch_name not in ('4-Seam Fastball', 'Cutter') then 1 else 0 end)/count(1) as Offspeed_Percentage
from lastpitchyankees l;

--2d top 5 most common last pitch for a starting pitcher vs relief pitcher (lastpitchyankees)

select *
from (
		select TT.pos, TT.pitch_name, TT.TimesThrown, rank() over(partition by TT.pos order by TT.TimesThrown desc) as PitchRank
		from (select yps.pos, lpy.pitch_name, count(1) as TimesThrown
				from lastpitchyankees lpy
				join yankeespitchingstats yps
				on yps.pitcher_id = lpy.pitcher
				group by 1, 2) as TT) as TT2
where TT2.PitchRank <= 5


--Question 3 Homerun Analysis

--3a what pitches have given up the most HRs (lastpitchyankees)

select pitch_name, count(1) as HRs
from lastpitchyankees l
where events = 'home_run'
group by 1
order by 2 desc;

--3b HRs given up by zone and pitch, top 5 most common

select zone, pitch_name, count(1) as HRs
from lastpitchyankees l 
where events = 'home_run'
group by 1, 2
order by count(1) desc
limit 5;

--3c HRs for each count type --> balls/strikes + type of pitcher

select yps.pos, lpy.balls, lpy.strikes, count(1) as HRs
from lastpitchyankees lpy
join yankeespitchingstats yps 
on yps.pitcher_id = lpy.pitcher 
where events = 'home_run'
group by 1, 2, 3
order by 4 desc;

--3d each pitcher's common counts to give up a HR (min 30 IP) *evaluated from a team perspective, not grouped by individual player

select yps.name, lpy.balls, lpy.strikes, count(1) as HRs
from lastpitchyankees lpy
join yankeespitchingstats yps 
on yps.pitcher_id = lpy.pitcher 
where events = 'home_run' and ip >= 30
group by 1, 2, 3
order by 4 desc;

--Question 4 Gerrit Cole aka the greatest Yankees pitcher since CC Sabathia and Mariano Rivera

--4a avg release speed, spin rate, strikeouts, most popular zone (lastpitchyankees)

select avg(release_speed) as Avg_release_speed, avg(release_spin_rate) as Avg_Spin_Rate,
		sum(case when events = 'strikeout' then 1 else 0 end) as strikeouts, max(zones.zone) as Zone
from lastpitchyankees lpy
join (select pitcher, zone, count(*) as zonenum
	  from lastpitchyankees lpy
	  where player_name = 'Cole, Gerrit'
	  group by 1, 2
	  order by 3 desc
	  limit 1) zones on zones.pitcher = lpy.pitcher where player_name = 'Cole, Gerrit';


--4b top pitches for each infield position where total pitches are over 5, rank 
	 -- context on the field/"diamond", infield positions are as listed:
	 		-- 5 is Third Base, 6 is Shortstop, 4 is Second Base, 3 is First Base
select *
from (
	select pitch_name, count(*) as num_times_hit, 'Third' Position 
	from lastpitchyankees l 
	where hit_location = 5 and player_name = 'Cole, Gerrit'
	group by 1
	union
	select pitch_name, count(*) as num_times_hit, 'Shortstop' Position 
	from lastpitchyankees l 
	where hit_location = 6 and player_name = 'Cole, Gerrit'
	group by 1
	union
	select pitch_name, count(*) as num_times_hit, 'Second' Position 
	from lastpitchyankees l 
	where hit_location = 4 and player_name = 'Cole, Gerrit'
	group by 1
	union 
	select pitch_name, count(*) as num_times_hit, 'First' Position 
	from lastpitchyankees l 
	where hit_location = 3 and player_name = 'Cole, Gerrit'
	group by 1) TP
where num_times_hit >=5
order by num_times_hit desc;

--4c show different balls/strikes as well as frequency when someone is on base

select balls, strikes, count(*) as frequency
from lastpitchyankees l
where (on_3b is not null or on_2b is not null or on_1b is not null)
	and player_name = 'Cole, Gerrit'
group by balls, strikes
order by 3 desc;


--4d what pitch causes the lowest launch speed

select distinct pitch_name, avg(launch_speed * 1.0) as avg_launch_speed
from lastpitchyankees l 
where player_name = 'Cole, Gerrit'
group by 1
order by 2 asc
limit 1;