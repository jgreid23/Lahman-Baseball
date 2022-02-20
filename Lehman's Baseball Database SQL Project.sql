/* 1) What range of years does the provided database cover? */

/* In this database, player's batting, fielding, and pitching stats are recorded. The database also contains game records for each 
team. These are all events that occured at some point of time and time data has been recorded for each event. The range of years 
for these events can be found because of this. */ 


select min(yearID) as [From], max(yearID) as [To]
from dbo.Batting 

select min(yearID) as [From], max(yearID) as [To]
from dbo.Pitching 

select min(yearID) as [From], max(yearID) as [To]
from dbo.Fielding

select min(yearkey) as [From], max(yearkey) as [To]
from dbo.HomeGames 


/* Results
From	 To
1871	2018

From	 To
1871	2018

From	 To
1871	2018

From	 To
1871	2018
*/


/* The database tracks baseball stats from 1871 to 2018. I also considered using the People table to find the earliest year that a 
player played their first game using the debut column and the latest year that a player played their final game using the finalGame 
column. Well this does give the correct range, I was concerned that that using the max() function would only give the latest year 
a player retired and not necessarily the latest year that stats were tracked. */


/* 2) Find the name and height of the shortest player in the database. How many games did he play in? What is the name of 
      the team for which he played? */

/* The 4 parts asked for are a player name, height, games played, and the team they played for. The last part implicates that
they only played for 1 team in their career, which is uncommon in the sport due to trades and free agency rights. Player name and 
height can be found in the People table. Games played can be found in the Appearances table. Team names can be found in the Teams 
table. The People table and Appearances table can be joined using the playerID Key. The Appearances and Teams table can be joined 
using the teamID key.*/ 


select top 1 players.nameFirst as First_Name, players.nameLast as Last_Name, 
             convert(varchar(20), floor(players.height/12.0)) + '''' + 
			 convert(varchar(20), convert(numeric(1),((players.height/12.0)%1) * 10)) + '"' as Height, 
             sum(app.G_all) as Games_Played, app.teamID as Team_ID, squad.[name] as Team_Name 
from dbo.Appearances as app
left join dbo.People as players
on app.playerID = players.playerID
left join (select distinct squad.teamID, squad.[name] 
           from dbo.Teams as squad)
squad on app.teamID = squad.teamID
where Height is not null
group by players.nameFirst, players.nameLast, Height, app.teamID, squad.[name]
order by Height asc


/* Results
First_Name	Last_Name	Height	Games_Played  Team_ID	  Team_Name
   Eddie	  Gaedel	 3'6"	     1	        SLA	    St. Louis Browns
*/


/* The shortest player in the database is Eddie Gaedel. He was 3'6" and played 1 game for the St. Louis Browns. 2 problems 
I encountered with my initial queries were 1) the height column was formatted as an integer to represent in inches. I believe this
was done to simplify inputting the data but I felt it was strange to report it only in inches. So for my Height column, I 
found how many feet he was by dividing height/12.0 and then found how many remaining inches he was by finding the remainder of 
height/12.0 in decimal form. I then converted the remaining decimal to numeric format and converted both numbers to character
values to represent in both feet and inches. The inch value is rounded up due to changing it to numeric.  2) By using the top and
asc commands, I first found the shortest player to be NULL height. This showed me that there is missing / unknown data in the 
database. To exclude this, I used the where clause to not include null values in the query. The query is designed to return the 
total number of games a player played for each team they played with in their career. If grouping by teams was not needed, the left
join with the Teams tables can be removed. */


/* 3) Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and 
      last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total 
	  salary earned. Which Vanderbilt player earned the most money in the majors? */ 

/* The elements needed are first name, last name, and salary with the filter that the player went to Vanderbilt University. First 
name and last name can be found in the People table. Salaries can be found in the Salaries table. University name can be found 
in the Schools table. There is no common key between the People and Schools tables. They can be connected though using the 
College Playing table, as the People and  College Playing tables have a common key of playerID and the College Playing and Schools 
tables have a common key of schoolID. The People and Salaries tables have a common key of playerID as well. */ 


select college.playerID, players.nameFirst as First_Name, players.nameLast as Last_Name, format(Total, 'C') as Total_Salary
from dbo.CollegePlaying as college
inner join dbo.People as players
on college.playerID = players.playerID
left join (select cash.playerID, sum(cash.salary) as Total
           from dbo.Salaries as cash
		   group by cash.playerID)
cash on college.playerID = cash.playerID
where college.schoolID in 
                         (select campus.schoolID
						  from dbo.Schools as campus
						  where campus.name_full = 'Vanderbilt University')
group by college.playerID, players.nameFirst, players.nameLast, Total
order by Total desc


/* Results
playerID	First_Name	Last_Name	 Total_Salary
priceda01	  David	      Price	    $81,851,296.00
alvarpe01	  Pedro	     Alvarez    $20,681,704.00
priorma01	  Mark	      Prior	    $12,800,000.00
sandesc01	  Scott	    Sanderson   $10,750,000.00
minormi01	  Mike	      Minor	     $6,837,500.00
corajo01	  Joey	      Cora	     $5,622,500.00
flahery01	  Ryan	    Flaherty	 $4,061,000.00
pauljo01	  Josh	      Paul	     $2,640,000.00
baxtemi01	  Mike	     Baxter	     $2,094,418.00
grayso01	  Sonny	      Gray	     $1,542,500.00
lewisje01	 Jensen	     Lewis	     $1,234,000.00
katama01	  Matt	      Kata	     $1,060,000.00
chrisni01	  Nick	   Christiani	   $500,000.00
sowerje01	 Jeremy	     Sowers	       $384,800.00
madissc01	 Scotti	     Madison	   $135,000.00
colliwi01	 Wilson	    Collins	          NULL
embresl01	  Slim	     Embry	          NULL
hendrha01	 Harvey	    Hendrick	      NULL
mooresc01	Scrappy	     Moore	          NULL
mossma01	   Mal	      Moss	          NULL
richaan01	 Antoan	   Richardson	      NULL
sewelri01	   Rip	     Sewell	          NULL
willimi01	  Mike	     Willis	          NULL
zeidjo01	  Josh	      Zeid	          NULL
*/


/* David Price has earned the most salary playing in the MLB with over 80 million, who went to Vanderbilt University. He is 1 of
24 players in the database to attend Vanderbilt University. Interestingly enough 9 of these players have a NULL value for 
Total_Salary. There is various reasons why this could be the case. One for example is who was paying the player's salary. Rookies
who are playing their first few games in the majors may still be getting paid by the minor league organzation, and their salary
would not count against the salary cap for the major league team. I believe the most likely reason for these NULL values is that
no salary data is available and verifiable for these players and therefore it is unknown. To connect the Schools table with the 
People table, I used a subquery in the where clause to retrieve the schoolID based on the condition that the name_full column in 
the Schools table equals 'Vanderbilt University'. The schoolID that is returned is 'vandy'. From there, the College Playing table 
can be filtered by schoolID = 'vandy'. */ 


/* 4) Using the fielding table, group players into three groups based on their position: label players with position OF as 
      "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
	  Determine the number of putouts made by each of these three groups in 2016. */ 

/* This question is best done using a case statement which splits players into 3 groups. The one filter for this question is for the
2016 season. The question does give to me that all the data needed is located in the Fielding table. */ 


select yearID as 'Year', sum(PO) as Total_Putouts,
	case 
		when POS = 'OF' then 'Outfield'
		when POS = 'SS' or POS = '1B' or POS = '2B' or POS = '3B' then 'Infield'
		when POS = 'P' or POS = 'C' then 'Battery'
	end as 'Group' 
from dbo.Fielding
where yearID = 2016 
group by yearID,
	case
		when POS = 'OF' then 'Outfield'
		when POS = 'SS' or POS = '1B' or POS = '2B' or POS = '3B' then 'Infield'
		when POS = 'P' or POS = 'C' then 'Battery'
	end 
order by Total_Putouts desc


/* Results
Year	Total_Putouts	Group
2016	   58935	   Infield
2016	   41424	   Battery
2016	   29560	   Outfield
*/


/* In 2016, Infielders made 58, 935 putouts, Battery 41, 424, and Outfielders 29, 560. Initially I thought I would only need 1 
case statement in the select clause for the aggregation. When I ran that query, it aggregated by specific positions and had only 
renamed them by the group they were assigned to. To aggregate by the groups needed, I also needed a case statement in the group 
by clause to make the distinction. */ 


/* 5) Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base 
      attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider 
	  only players who attempted at least 20 stolen bases. */

/* All the data needed for this query is located in the Batting table. To find the stolen base percentage, I will need to include 
the calculation (SB/(SB + CS)) using the SB and CS columns. The data types for these 2 columns are small integers, so I will also
need to convert the data type in the query to make it a percentage. Two filters that need to be applied to the query are that
it relates to the 2016 season and the player must have had at least 20 stolen base attempts. */ 


select top 1 bat.playerID, nameFirst as First_Name, nameLast as Last_Name, format(SB/(SB+CS), 'P2') as SB_Percentage, 
             SB as Stolen_Bases, CS as Caught_Stealing, (SB + CS) as Total_Attempts 
from dbo.Batting as bat
join dbo.People as player
on bat.playerID = player.playerID
where bat.yearID = 2016 and (SB + CS) >= 20 
order by SB_Percentage desc


/* Results
playerID	First_Name	Last_Name	SB_Percentage	Stolen_Bases	Caught_Stealing	   Total_Attempts
owingch01	  Chris	     Owings	       91.30%	         21	               2	             23
*/


/* Chris Owings had the best stolen base percentage in 2016 at 91.30%. I realized after my intial write-up that player names were
not included in the batting table and only finding the playerID didn't make much sense. To find the player name, I used an inner 
join between the Batting and People tables with the common key of playerID. */


/* 6) Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do
      the same for home runs per game. Do you see any trends? */ 

/* I was a little concerned when I read the years needed to be grouped into decades. I realized though that the yearID columns in
various tables are formatted to integers, so a division calculation can help with rounding. To find the total number of 
strikeouts, I can sum the strikeout totals for each player in the Batting table. To find the total number of homeruns, I can sum
the homerun totals for each player also found in the Batting table. To find the total number of games, I can sum the home game
totals from the Home Games table. By summing only the home games, this will avoid the cross over of games between teams if I
were just to sum each team's total games played in a year. */ 


select convert(nvarchar(20),((yearkey)/10) * 10) + '  - ' + convert(nvarchar(20),(((yearkey)/10) * 10) + 9) as Decade, 
       format((avg(Total_SO)/sum(games)), 'N2') as Avg_SO, format((avg(Total_HR)/sum(games)), 'N2') as Avg_HR
from dbo.HomeGames as home
left join (select ((yearID)/10) * 10 as years, cast(sum(SO) as numeric(10,2)) as Total_SO, 
           cast(sum(HR) as numeric(10,2)) as Total_HR
           from dbo.Batting as bat
		   group by ((yearID)/10) * 10
		   having min(yearID) >= 1920) 
bat on bat.years = home.yearkey
group by ((yearkey)/10) * 10
having min(yearkey) >= 1920
order by Decade asc 


/* Results
   Decade	   Avg_SO  Avg_HR
1920  - 1929	5.62	0.80
1930  - 1939	6.63	1.09
1940  - 1949	7.09	1.05
1950  - 1959	8.79	1.69
1960  - 1969	11.43	1.64
1970  - 1979	10.29	1.49
1980  - 1989	10.73	1.62
1990  - 1999	12.30	1.91
2000  - 2009	13.12	2.15
2010  - 2019	15.42	2.06
*/


/* Since the 1920s, the average number of strikeouts per game has nearly tripled and the average number of homeruns per game
has increased almost 2.5 times. Since I needed sum aggregations from both the Home Games table and the Batting table, I used
a subquery in a left join statement to avoid any cross over. To avoid any grouping issues in the outer select statement relating
to the aggregations in the subquery, I took the avg of sum(SO) abd sum(HR), which is just the total SO and HR divided by 1.
Originally I was going to just list the decades by their first year (i.e. 1920). To do this for each year in the decade, I 
divided each year by 10 and then multipled by 10 since the yearID and yearkey columns were both in integer format 
(i.e. 1922 / 10 = 192, 192 x 10 = 1920). I felt though this was not descriptive enough for the Decade column, so I converted
the integer calculation for each decade into a variable character format, added a '-', did the integer calculation again 
+ 9 years, and converted that calculation in a variable character format to provide a range of years for each decade. */ 


/* 7) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest 
      number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of 
	  wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How 
	  often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the 
	  time? */

/* All the data needed for these questions is located in the Series Post and Teams tables. The Series Post table has the teamID
value for each World Series winner in the teamIDwinner column. This needs to be condition by the round column having a value
of 'WS'. The Teams table has the number of games won by each team in each season and has the team name for each team. I'll likely
need to use the min and max functions as the question is asking for min and max values based on certain conditions. To connect
the 2 tables, I'll need to use the yearID as a key. */


select top 1 post.yearID as [Year], teams.[name] as Team, teams.W as Season_Wins, rank() over (order by teams.W asc) as [Rank],
             case 
                 when post.teamIDwinner = teams.teamID then 'Yes' 
	             when post.teamIDwinner <> teams.teamID then 'No'
             end as 'World_Series_Winner?'
from dbo.SeriesPost as post
join dbo.Teams as teams
on post.yearID = teams.yearID 
where post.yearID between 1970 and 2016 and post.[round] = 'WS' and post.teamIDwinner = teams.teamID
group by teams.W, teams.[name], post.yearID,
          case 
               when post.teamIDwinner = teams.teamID then 'Yes' 
	           when post.teamIDwinner <> teams.teamID then 'No'
		  end

union

select top 1 post.yearID as [Year], teams.[name] as Team, teams.W as Season_Wins, rank() over (order by teams.W desc) as [Rank],
             case 
                 when post.teamIDwinner = teams.teamID then 'Yes' 
	             when post.teamIDwinner <> teams.teamID then 'No'
             end as 'World_Series_Winner?'
from dbo.SeriesPost as post
join dbo.teams as teams
on post.yearID = teams.yearID 
where post.yearID between 1970 and 2016 and post.[round] = 'WS' and post.teamIDwinner <> teams.teamID 
group by post.yearID, teams.[name], teams.W, 
         case 
             when post.teamIDwinner = teams.teamID then 'Yes' 
	         when post.teamIDwinner <> teams.teamID then 'No'
         end 


select teams.yearID as [Year], teams.[name] as Team_Name, teams.W as Wins  
from dbo.Teams as teams
where teams.yearID between 1970 and 2016 and teams.WSWin = 'Y'

intersect

select teams.yearID as [Year], teams.[name] as Team_Name, max(Team_Wins) as Wins
from dbo.Teams as teams
inner join (select franch.yearID,  max(franch.W) as Team_Wins
            from dbo.Teams as franch
			where franch.yearID between 1970 and 2016 
			group by franch.yearID)
franch on teams.yearID = franch.yearID 
where teams.yearID between 1970 and 2016 and Team_Wins = teams.W
group by teams.yearID, teams.[name]
order by teams.yearID asc 


/* Results
Year	       Team	          Season_Wins	  Rank	World_Series_Winner?
1981	Los Angeles Dodgers	      63	       1	         Yes
2001	Seattle Mariners	      116	       1	         No

Year	    Team_Name	        Wins
1970	Baltimore Orioles	    108
1975	Cincinnati Reds	        108
1976	Cincinnati Reds	        102
1978	New York Yankees	    100
1984	Detroit Tigers	        104
1986	New York Mets	        108
1989	Oakland Athletics	     99
1998	New York Yankees	    114
2007	Boston Red Sox	         96
2009	New York Yankees	    103
2013	Boston Red Sox	         97
2016	Chicago Cubs	        103
*/


/* First, I noticed after I started working on the problem that the Teams table has a column called WSWin, which has value of 'Y'
if that team won the World Series that year or a value of 'N' if that team did not win the World Series that year. This 
eliminated any need for the Series Post table. The learning lesson from this is that I need to take a better look at tables to
see the data available to me. The 2001 Seattle Mariners won the most number of regular season games without winning the World 
Series at 116. The 1981 Los Angeles Dodgers won the least number of regular season games while winning the World Seriest at 63. 
Doing a little research online, I found out that there was a stoppage in the 1981 season. In this case, it was a players strike 
that caused the stoppage. My inital plan to solve this problem was to union 2 queries, returning the top row for each, based on 
the condition of if they won the World Series and it happened between 1970 and 2016. One challenge that occured is that with the 
order by clause in a union, it has to appear at the end of the 2nd query and it applies to both queries. This made my plan more 
diffcult to execute as the query to find the team with the most regular season wins and no world series win was going to be 
ordered by season wins descending and the query to find the team with the least regular season wins and a world series win was 
going to be ordered by season wins ascending. To address to this problem, I included a rank column in each select statement that 
used the ranked function to assign a value to each team based on their number of regular season wins. In the rank function, you 
can assign the order by clause there. This eliminated the need for the order by clause at the end of the union and now just 
returned the top row for each query. 

Between 1970 and 2016, 12 teams won the most games in a regular season and ended up winning the World Series that year. That 
equates to about 25% of the time (12/47). My initial plan for this question was to use the intersect clause, with one query 
retrieving the World Series winner for each year in the time frame defined, and the other query retrieving the team with the most 
regular season wins for each year in the time frame defined. To find the teams with the most wins by year, I used a subquery in 
the 2nd query to retrieve the most games won by year from the Teams tables, joined it to the outer query with the yearID as the 
key, and then assigned the condition that most wins from the inner query had to equal the wins from the outer query by year. Some
years, there were multiple teams tied for the most wins in a season. The intersect clause though would filter out the teams that
did not win a World Series for those seasons. */ 


/* 8) Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per 
      game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where 
	  there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average 
	  attendance. */

/* All the data needed can be found in the Home Games and Teams tables. The Home Games table has the total attendance and number of 
home games each team had for each year. The Teams tables has the team names and the home park they played in for each year. These 2 
tables can be connected using yearID and teamID as keys. */


select top 5 home.yearkey as [Year], teams.[name] as Team_Name, teams.park as Park,
            (home.attendance /home.games) as Avg_Attendance
from dbo.HomeGames as home
join dbo.Teams as teams
on home.yearkey= teams.yearID and home.teamkey = teams.teamID
where home.yearkey = 2016 and home.games >= 10
order by Avg_Attendance desc

select top 5 home.yearkey as [Year], teams.[name] as Team_Name, teams.park as Park,
             (home.attendance /home.games) as Avg_Attendance
from dbo.HomeGames as home
join dbo.Teams as teams
on home.yearkey= teams.yearID and home.teamkey = teams.teamID
where home.yearkey = 2016 and home.games >= 10
order by Avg_Attendance asc

/* Results
Year	      Team_Name	           Park	           Avg_Attendance
2016	Los Angeles Dodgers	  Dodger Stadium	       45719
2016	St. Louis Cardinals	  Busch Stadium III	       42524
2016	Toronto Blue Jays	   Rogers Centre	       41877
2016	San Francisco Giants	 AT&T Park	           41546
2016	     Chicago Cubs	   Wrigley Field	       39906

Year	      Team_Name	           Park	           Avg_Attendance
2016	   Tampa Bay Rays	  Tropicana Field	       15878
2016	  Oakland Athletics	   O.co Coliseum	       18784
2016	  Cleveland Indians	 Progressive Field	       19650
2016	    Miami Marlins	   Marlins Park	           21405
2016	  Chicago White Sox	 U.S. Cellular Field	   21559
*/


/* To connect the team name and park name from the Teams table to the attendance figures in the Home Games table, I used a join 
with both the yearID and teamID as keys. To find the top 5 and bottom average attendance teams for 2016, I used the top clause to 
retrieve only the top 5 teams and the order by clause by either descending or ascending to retrieve the top or bottom of the list.
*/ 


/* 9) Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
      Give their full name and the teams that they were managing when they won the award. */


/*The Awards Managers table only includes the Player ID and League ID for the year they won the TSN Manager of the Year Award. To
find their full name, I will need to connect the Awards Managers table with the People table using the playerID key. To find the 
team name, I will need to call the Teams table. The problem is that there is no away to connect the Manager to the team name only
using those 2 tables. So I will need to connect the Awards Manager table with the Managers table first using the playerID and 
yearID keys, and then connect the Managers table to the Teams table using the teamID and yearID keys. */


select distinct man.playerID as Player_ID, people.namefirst as First_Name, people.nameLast as Last_Name, 
                man.yearID as [Year], coach.lgID as League, coach.teamID as Team_ID, team.[name] as Team_Name,
				count(man.playerID) over (partition by man.playerID order by man.yearID) as Total_for_Manager
from dbo.AwardsManagers as man
join dbo.People as people
on man.playerID = people.playerID
left join (select distinct coach.playerID, coach.yearID, coach.lgID, coach.teamID
           from dbo.Managers as coach)
coach on man.yearID = coach.yearID and man.playerID = coach.playerID
left join (select distinct team.teamID, team.yearID, team.[name]
           from dbo.Teams as team)
team on coach.teamID = team.teamID and coach.yearID = team.yearID
where man.awardID = 'TSN Manager of the Year' and man.playerID in
                                                                 (select A.playerID 
																  from dbo.AwardsManagers as  A
																  join dbo.Managers as B
                                                                  on A.yearID = B.yearID and A.playerID = B.playerID
                                                                  where A.awardID = 'TSN Manager of the Year' and B.lgID = 'AL')
                                              and man.playerID in
																 (select C.playerID 
                                                                  from dbo.AwardsManagers as C
                                                                  join dbo.Managers as D
                                                                  on C.yearID = D.yearID and C.playerID = D.playerID
                                                                  where C.awardID = 'TSN Manager of the Year' and D.lgID = 'NL')
order by people.namefirst asc, year asc 


/*Player_ID	First_Name	Last_Name	Year	League	Team_ID	Team_Name	Total_for_Manager
virdobi01	Bill	Virdon	1974	AL	NYA	New York Yankees	1
virdobi01	Bill	Virdon	1980	NL	HOU	Houston Astros	2
coxbo01	Bobby	Cox	1985	AL	TOR	Toronto Blue Jays	1
coxbo01	Bobby	Cox	1991	NL	ATL	Atlanta Braves	2
coxbo01	Bobby	Cox	1993	NL	ATL	Atlanta Braves	3
coxbo01	Bobby	Cox	1999	NL	ATL	Atlanta Braves	4
coxbo01	Bobby	Cox	2002	NL	ATL	Atlanta Braves	5
coxbo01	Bobby	Cox	2003	NL	ATL	Atlanta Braves	6
coxbo01	Bobby	Cox	2004	NL	ATL	Atlanta Braves	7
coxbo01	Bobby	Cox	2005	NL	ATL	Atlanta Braves	8
johnsda02	Davey	Johnson	1997	AL	BAL	Baltimore Orioles	1
johnsda02	Davey	Johnson	2012	NL	WAS	Washington Nationals	2
leylaji99	Jim	Leyland	1988	NL	PIT	Pittsburgh Pirates	1
leylaji99	Jim	Leyland	1990	NL	PIT	Pittsburgh Pirates	2
leylaji99	Jim	Leyland	1992	NL	PIT	Pittsburgh Pirates	3
leylaji99	Jim	Leyland	2006	AL	DET	Detroit Tigers	4
*/


/* 4 managers have won the TSN Manager of the Year award in both leagues: Bill Virdon, Bobby Cox, Davey Johnson, and Jim Leyland.
Bill Virdon won 1 in the American League with the New York Yankees and 1 in the National League with the Houston Astros. Bobby 
Cox won 1 in the American League with the Toronto Blue Jays and 7! in the National League with the Atlanta Braves. Davey Johnson
won 1 in the American League with the Baltimore Orioles and 1 in the National League with the Washington Nationals. Jim Leyland 
won 1 in the American League with the Detroit Tigers and 3 in the National League with the Pittsburgh Pirates. One challenge that
occured while taking on this problem was with the Awards Managers table, as I found out that before 1985, only 1 manager was 
given the TSN Manager of the Year award. In the table these award winners had a lgID value of 'ML' (Major League). This created
the challenge of determining what league they managed in, AL or NL. To address this, I used a subquery of the Managers table to
retrieve the lgID from there using the playerID and yearID keys. I also had to condition in the where clause that a playerID 
value had to appear at least twice with 1 lgID value of 'AL' and 1 lgID value of 'NL', based on the join of the Awards Managers
and Managers tables with both the playerID and yearID key. */ 































             


	                                     



	                        










































































