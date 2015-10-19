-- http://stattrek.com/regression/regression-example.aspx?Tutorial=AP

select Id, Score into #AppScores 
from ( values 
	(1, 95), (2, 85), (3, 80), (4, 70), (5, 60)
) AppScores (Id, Score)

;

select Id, Score into #StatScores 
from ( values 
	(1, 85), (2, 95), (3, 70), (4, 65), (5, 70)
) StatScores (Id, Score)


;

select Id, Score
from 
	(
		select 
			Id, 
			Score -- , 
			-- case when Score = max(Score) then 1 else 0 end as MaxScore
		from #AppScores
		group by Id, Score
	) S, 
	(
		select max(Score) as MaxScore from #AppScores
	) M
where Score = MaxScore

;


declare @AvgAppScore float 
declare @SumAppScore float 

set @SumAppScore = 1.0*( select sum(Score) from #AppScores )
set @AvgAppScore = ( select avg(Score) from #AppScores )

;


declare @AvgStatScore float 
declare @SumStatScore float 

set @SumStatScore = 1.0*( select sum(Score) from #StatScores )
set @AvgStatScore = ( select avg(Score) from #StatScores )

;

select @SumAppScore, @SumStatScore, @AvgAppScore, @AvgStatScore

;


select 
	A.Id, 
	A.Score, 
	S.Score, 
	(A.Score-@AvgAppScore) as DiffApps, 
	(S.Score-@AvgStatScore) as DiffStats, 
	power(A.Score-@AvgAppScore, 2) as DiffAppSquared, 
	power(S.Score-@AvgStatScore, 2) as DiffStatSquared,
	(1.0*(A.Score-@AvgAppScore)) * (1.0*(S.Score-@AvgStatScore)) as DiffAppsDiffStats
from 
	#AppScores A,
	#StatScores S
where A.Id = S.Id


;

select 
	sum(power(A.Score-@AvgAppScore, 2)) as SumDiffAppSquared, 
	sum(power(S.Score-@AvgStatScore, 2)) as SumDiffStatSquared,
	sum((1.0*(A.Score-@AvgAppScore)) * (1.0*(S.Score-@AvgStatScore))) as SumDiffAppsDiffStats
from 
	#AppScores A,
	#StatScores S
where A.Id = S.Id






;

declare @CoeffecientEstimate float
set @CoeffecientEstimate = (
	select sum((1.0*(A.Score-@AvgAppScore)) * (1.0*(S.Score-@AvgStatScore))) / sum(power(A.Score-@AvgAppScore, 2)) as CoeffecientEstimate
	from 
		#AppScores A,
		#StatScores S
	where A.Id = S.Id
)

;

select 77 - (@CoeffecientEstimate * 78)

;


drop table #AppScores
drop table #StatScores
