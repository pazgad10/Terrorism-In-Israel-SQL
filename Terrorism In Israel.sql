SELECT *
FROM PortfolioProject.dbo.TerrorismInIsrael

--Starting by data cleaning
UPDATE PortfolioProject..TerrorismInIsrael
SET city = 'Sderot'
WHERE city = 'Sederot'

ALTER TABLE TerrorismInIsrael
DROP COLUMN attacktype2_txt

ALTER TABLE TerrorismInIsrael
DROP COLUMN attacktype3_txt

SELECT provstate
FROM PortfolioProject..TerrorismInIsrael
WHERE provstate is null

UPDATE PortfolioProject..TerrorismInIsrael
SET provstate = city
WHERE provstate is null

UPDATE PortfolioProject..TerrorismInIsrael
SET target1 = targtype1_txt
WHERE target1 is null

UPDATE PortfolioProject..TerrorismInIsrael
SET weapdetail = 'Unknown'
WHERE weapdetail is null


UPDATE PortfolioProject..TerrorismInIsrael
SET nkill = 0
WHERE nkill is null

UPDATE PortfolioProject..TerrorismInIsrael
SET nwound = 0
WHERE nwound is null

UPDATE PortfolioProject..TerrorismInIsrael
SET hostkidoutcome = 0
WHERE hostkidoutcome is null

-- Looking at the city where most were murdered 
SELECT city, SUM(nkill) total_murdered_per_city
FROM PortfolioProject..TerrorismInIsrael
GROUP BY city
ORDER BY total_murdered_per_city desc

--Looking at the year with where most were murdered  
SELECT iyear, SUM(nkill) total_murdered
FROM PortfolioProject..TerrorismInIsrael
GROUP BY  iyear
ORDER BY total_murdered desc
--As we can tell those are the years 2001-2003 which is where the 'second intifada' has been occurred

--Looking at the number of murders and wounded
SELECT SUM(nkill) sum_murders, SUM(nwound) sum_wonded
FROM PortfolioProject..TerrorismInIsrael

--Looking at the most common terrorism attack
SELECT eventid, attacktype1_txt, COUNT(attacktype1_txt) OVER (PARTITION BY attacktype1_txt) common_attack_type
FROM PortfolioProject..TerrorismInIsrael
GROUP BY eventid, attacktype1_txt
ORDER BY common_attack_type desc

--Looking at rolling murdered in Jerusalem 
SELECT eventid, city, iyear, iday, imonth, nkill,
SUM(nkill) OVER (PARTITION BY city ORDER BY iyear, iday, imonth) rolling_murdered
FROM PortfolioProject..TerrorismInIsrael
WHERE city like '%Jerusalem%' 

--Doing some farther data cleaning after finding there is 'Jerusalem district' & 'Arab East Jerusalem' which didn't included in 'Jerusalem'
UPDATE PortfolioProject..TerrorismInIsrael
SET city = 'Jerusalem'
WHERE eventid = '200202180001'

UPDATE PortfolioProject..TerrorismInIsrael
SET city = 'Jerusalem'
WHERE eventid = '199408120006'

--Looking at the largest victim group of the terrorism
SELECT eventid, targtype1_txt, COUNT(targtype1_txt) OVER (PARTITION BY targtype1_txt) largest_victim_gp
FROM PortfolioProject..TerrorismInIsrael
GROUP BY eventid, targtype1_txt
ORDER BY largest_victim_gp desc
--Sadly private citizens are the largest amount of victims by a huge gap

--Shows what percentage of terror attacks were succeed using CTE
ALTER TABLE TerrorismInIsrael
ADD all_the_attacks float

UPDATE PortfolioProject..TerrorismInIsrael
SET all_the_attacks = 1
WHERE all_the_attacks is NULL

WITH CTE_Terrorism as
(SELECT eventid, city, iyear, iday, imonth,success, all_the_attacks, COUNT(success) OVER (PARTITION BY success) num_of_successes,
SUM(all_the_attacks) OVER (PARTITION BY all_the_attacks) as all_the_attacks1
FROM PortfolioProject..TerrorismInIsrael
GROUP BY eventid, city, iyear, iday, imonth, success, all_the_attacks
)
SELECT success, num_of_successes, all_the_attacks1, (num_of_successes/all_the_attacks1)*100 as percentage_attacks_succeed
FROM CTE_Terrorism
GROUP BY success, num_of_successes, all_the_attacks1

--Looking at all terror attacks successes sorted by city
SELECT city, success, COUNT(success) OVER (PARTITION BY city) num_of_successes
FROM PortfolioProject..TerrorismInIsrael
WHERE success like '1' 
--city like 'Jerusalem' and
ORDER BY num_of_successes desc

--Looking at most dangerous city by more than 100 succeessful attacks
WITH CTE_Terrorism as
(SELECT eventid, city, iyear, iday, imonth,success, all_the_attacks, COUNT(success) OVER (PARTITION BY city,success) num_of_successes,
SUM(all_the_attacks) OVER (PARTITION BY city,all_the_attacks) as all_the_attacks1
FROM PortfolioProject..TerrorismInIsrael
GROUP BY eventid, city, iyear, iday, imonth, success, all_the_attacks
)
SELECT city, success, num_of_successes, all_the_attacks1, (num_of_successes/all_the_attacks1)*100 as percentage_attacks_succeed
FROM CTE_Terrorism
WHERE success like '1' and num_of_successes > 100
GROUP BY city, success, num_of_successes, all_the_attacks1
ORDER BY percentage_attacks_succeed desc

/*We can assume that Jerusalem is the city with most murdered,
but the most dangerous city is "Sderot" which has huge amount of successful attacks percentage of 89.79% */ 
















