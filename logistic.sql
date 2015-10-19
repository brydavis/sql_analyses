-- http://vassarstats.net/logreg1.html

select Id, GestAge, BrstFed into #FeedCohort 
from ( values 
	(1, 28, 0), (2, 28, 0), (3, 28, 0), (4, 28, 0), (5, 28, 1), (6, 28, 1), (7, 29, 0), (8, 29, 0), (9, 29, 0), (10, 29, 1), (11, 29, 1), (12, 30, 0), (13, 30, 0), (14, 30, 1), (15, 30, 1), (16, 30, 1), (17, 30, 1), (18, 30, 1), (19, 30, 1), (20, 30, 1), (21, 31, 0), (22, 31, 0), (23, 31, 1), (24, 31, 1), (25, 31, 1), (26, 31, 1), (27, 31, 1), (28, 31, 1), (29, 31, 1), (30, 32, 0), (31, 32, 0), (32, 32, 0), (33, 32, 0), (34, 32, 1), (35, 32, 1), (36, 32, 1), (37, 32, 1), (38, 32, 1), (39, 32, 1), (40, 32, 1), (41, 32, 1), (42, 32, 1), (43, 32, 1), (44, 32, 1), (45, 32, 1), (46, 32, 1), (47, 32, 1), (48, 32, 1), (49, 32, 1), (50, 33, 0), (51, 33, 1), (52, 33, 1), (53, 33, 1), (54, 33, 1), (55, 33, 1), (56, 33, 1), (57, 33, 1), (58, 33, 1), (59, 33, 1), (60, 33, 1), (61, 33, 1), (62, 33, 1), (63, 33, 1), (64, 33, 1) 
) FeedCohort (Id, GestAge, BrstFed)

;


select 
	FC.GestAge, 
	sum(BrstFed) as BrstFed, 
	count(FC.GestAge) as AgeCohorts, 
	(sum(BrstFed)*1.0) / count(FC.GestAge) as BrstFedProbability,
	(Y.Total * 1.0) / N.Total as BrstFedOdds,
	log((Y.Total * 1.0) / N.Total) as BrstFedLogOdds
	-- (count(Y.GestAge) * 1.0) / count(N.GestAge) as BrstFedOdds,
	-- log((count(Y.GestAge) * 1.0) / count(N.GestAge)) as BrstFedLogOdds

	into #Reformed

from 
	#FeedCohort FC,
	-- #FeedCohort Y
	-- #FeedCohort N
	(
		select GestAge, count(GestAge) as Total 
		from  #FeedCohort 
		where BrstFed = 0 
		group by GestAge
	) N,
	(
		select GestAge, count(GestAge) as Total 
		from  #FeedCohort 
		where BrstFed = 1 
		group by GestAge
	) Y

where FC.GestAge = Y.GestAge and FC.GestAge = N.GestAge
	-- and Y.BrstFed = 1 and N.BrstFed = 0

group by FC.GestAge, Y.Total, N.Total
;




-- -- TODO

-- -- => Insert "BrstFedLogOdds" back into "FeedCohort" table
-- -- => Refactor regression to use "FeedCohort" data



-- select Id, Score into #AppScores 
-- from ( values 
-- 	(1, 95), (2, 85), (3, 80), (4, 70), (5, 60)
-- ) AppScores (Id, Score)

-- ;

-- select Id, Score into #StatScores 
-- from ( values 
-- 	(1, 85), (2, 95), (3, 70), (4, 65), (5, 70)
-- ) StatScores (Id, Score)


-- ;

-- select Id, Score
-- from 
-- 	(
-- 		select 
-- 			Id, 
-- 			Score -- , 
-- 			-- case when Score = max(Score) then 1 else 0 end as MaxScore
-- 		from #AppScores
-- 		group by Id, Score
-- 	) S, 
-- 	(
-- 		select max(Score) as MaxScore from #AppScores
-- 	) M
-- where Score = MaxScore

-- ;


declare @AvgGestAge float 
declare @SumGestAge float 

set @SumGestAge = 1.0*( select sum(GestAge) from #Reformed )
set @AvgGestAge = ( select avg(GestAge) from #Reformed )

;


declare @AvgLogOdds float 
declare @SumLogOdds float 

set @SumLogOdds = 1.0*( select sum(BrstFedLogOdds) from #Reformed )
set @AvgLogOdds = ( select avg(BrstFedLogOdds) from #Reformed )

;

select 
	GestAge,
	BrstFedLogOdds,

	(GestAge-@AvgGestAge) as DiffGestAge, 
	(BrstFedLogOdds-@AvgLogOdds) as DiffLogOdds, 
	power(GestAge-@AvgGestAge, 2) as DiffGestAgeSquared, 
	power(BrstFedLogOdds-@AvgLogOdds, 2) as DiffLogOddsSquared,
	(1.0*(GestAge-@AvgGestAge)) * (1.0*(BrstFedLogOdds-@AvgLogOdds)) as DiffGestAgeDiffLogOdds
from #Reformed


;

select 
	sum(power(GestAge-@AvgGestAge, 2)) as SumDiffGestAgeSquared, 
	sum(power(BrstFedLogOdds-@AvgLogOdds, 2)) as SumDiffLogOddsSquared,
	sum((1.0*(GestAge-@AvgGestAge)) * (1.0*(BrstFedLogOdds-@AvgLogOdds))) as SumDiffGestAgeDiffLogOdds
from #Reformed







;

declare @CoeffecientEstimate float
set @CoeffecientEstimate = (
	select sum((1.0*(GestAge-@AvgGestAge)) * (1.0*(BrstFedLogOdds-@AvgLogOdds))) / sum(power(GestAge-@AvgGestAge, 2)) as CoeffecientEstimate
	from #Reformed
)

;

select @CoeffecientEstimate, @AvgLogOdds - (@CoeffecientEstimate * @AvgGestAge)

;


drop table #Reformed
drop table #FeedCohort

;














