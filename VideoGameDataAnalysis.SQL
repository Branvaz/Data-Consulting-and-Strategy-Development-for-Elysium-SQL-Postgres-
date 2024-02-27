CREATE TABLE VideoGameData (
    Name VARCHAR(100),
    Platform VARCHAR(50),
    Year INT,
    Genre VARCHAR(50),
    Publisher VARCHAR(100),
    NA_Sales DECIMAL(8, 2),
    EU_Sales DECIMAL(8, 2),
    JP_Sales DECIMAL(8, 2),
    Other_Sales DECIMAL(8, 2),
    Global_Sales DECIMAL(8, 2)
);

ALTER TABLE VideoGameData
ALTER COLUMN Year TYPE VARCHAR(10);  
ALTER TABLE VideoGameData ALTER COLUMN Name TYPE VARCHAR(255);
SELECT * FROM VideoGameData;

--Let's start by examining the trend of global sales over time.
SELECT Year, SUM(Global_Sales) AS Total_Sales
FROM VideoGameData
GROUP BY Year
ORDER BY Year;
--Looks like sales increased from 1980 then maxed at 2008, then have fallen off till 2020. I'll keep that in mind when looking at the data.

--Now I wanna to start by looking at the top selling games of all time

SELECT Name, Global_Sales
FROM VideoGameData
ORDER BY Global_Sales DESC
LIMIT 10;
--Games r in the following command

--OK, I need some information about these games. I wanna know what genre they are and go from there.
SELECT Name, Genre
FROM VideoGameData
WHERE Name IN ('Wii Sports', 'Mario Kart Wii', 'Super Mario Bros.', 
               'Pokemon Red/Pokemon Blue', 'Tetris', 'New Super Mario Bros.',
               'Wii Play', 'Duck Hunt', 'New Super Mario Bros Wii');

--Sports, Platform, racing, Role-Playing, Puzzle, Platform, Misc, Shooter, Puzzle,Platform. Looks like Platform is super popular.
--Lets see if that matchs with the rest of the data

SELECT Genre, SUM(Global_Sales) AS Total_Sales
FROM VideoGameData
GROUP BY Genre
ORDER BY Total_Sales DESC;

--Interesting. It seems Action, Sports, Shooter, Role-Playing, then Platform is the top 5th most selling genre.
--Lets wrap up the genre arugment. I wanna see which genres have done best in recent years.

SELECT Genre, SUM(Global_Sales) AS Total_Sales
FROM VideoGameData
WHERE CAST(Year AS INT) >= 2014
GROUP BY Genre
ORDER BY Total_Sales DESC;
--Had too change year to an interger for this. The issue is the N/As in the year column. I would remove these, but I'm making the call the rest of the data attached to these is still valuable even though we don't know which year they were released

SELECT Genre, SUM(Global_Sales) AS Total_Sales
FROM VideoGameData
WHERE CASE WHEN Year ~ '^[0-9]+$' THEN CAST(Year AS INT) ELSE 0 END >= 2014
GROUP BY Genre
ORDER BY Total_Sales DESC;
--Looks like from 2014 and up Action, then shooter, then sports, then role-playing
--Based off these past queries, I'm going to make the call to advise our company foucs on developing a sports or action game.

--I wanna create a quick view for the genre data so I dont have to go back to all my queries before
CREATE OR REPLACE VIEW GenreSalesSummary AS
SELECT 
    Genre,
    SUM(Global_Sales) AS Total_Sales
FROM 
    VideoGameData
WHERE 
    Year !~ '[^0-9]' AND CAST(Year AS INT) >= 2014
GROUP BY 
    Genre
ORDER BY 
    Total_Sales DESC;

SELECT * FROM GenreSalesSummary;
--Great, now thats all I have to run to look back at the genre data.

-- I should find what platform was most popular so I can guide my company on what type of device they should aim to make the game for.
SELECT Platform, COUNT(*) AS Games_Count
FROM VideoGameData
GROUP BY Platform
ORDER BY Games_Count DESC;
--DS, PS2, PS3, Wii, X360, PSP,PS r the major sellers. 5 console, 2 handheld and the handeheld don't have outlier phenonmal sales. It looks like our company should make our game for a console.

--I want to make sure we start developing games for the right region. Lets divide sales up by that variabe
SELECT 
    SUM(NA_Sales) AS Total_NA_Sales,
    SUM(EU_Sales) AS Total_EU_Sales,
    SUM(JP_Sales) AS Total_JP_Sales,
    SUM(Other_Sales) AS Total_Other_Sales
FROM VideoGameData;
--NA sales has over twice the amount of sales as the 2nd best region, EU. We should look to focus on this region

--Creating our own personal company stragey is our goal.Howeevr, we should look to see what strageties have worked before in this industry. Lets find which devleoper has done the best in sales.
SELECT Publisher, SUM(Global_Sales) AS Total_Sales
FROM VideoGameData
GROUP BY Publisher
ORDER BY Total_Sales DESC
LIMIT 5;
--Nintendo and Electronic Arts both have fantastic sales. 

--Lets see how well these companies did in our desired region, NA.

SELECT Publisher, SUM(NA_Sales) AS Total_NA_Sales
FROM VideoGameData
GROUP BY Publisher
ORDER BY Total_NA_Sales DESC
LIMIT 10;
--Both were top 2 perfomers in the region.

SELECT Publisher, Genre, COUNT(*) AS Game_Count
FROM VideoGameData
WHERE Publisher IN ('Nintendo', 'Electronic Arts')
AND Genre IN ('Action', 'Sports')
AND NA_Sales IS NOT NULL
GROUP BY Publisher, Genre;
--Nintendo had 79 action and 55 sports games in NA, electronic arts had 183 action and 561 sports games sold in NA. Looks like Electronic sports has a lot of experience in the gaming genre we want to go into.

SELECT 
    Publisher,
    (SUM(CASE WHEN Genre IN ('Action', 'Sports') THEN NA_Sales ELSE 0 END) /
     SUM(NA_Sales) * 100) AS Percentage
FROM 
    VideoGameData
WHERE 
    Publisher IN ('Nintendo', 'Electronic Arts')
    AND NA_Sales IS NOT NULL
GROUP BY 
    Publisher;
--54% of Electronic Arts were action or sports, nintendo had 20%. Electronic Arts business plan might be more approiate for our goal, but we can keep nintendo in mind due to thier high performace.

--Now that I have a better idea of where to focus my analysis, lets see how the action and sports genre did on different gaming platforms.

SELECT Genre, Platform, SUM(Global_Sales) AS Total_Sales
FROM VideoGameData
WHERE Genre IN ('Action', 'Sports')
GROUP BY Genre, Platform
ORDER BY Genre, Total_Sales DESC;

--The top performing platforms for action was PS3, PS2, and X360. For Sports it was Wii, PS2, and X360. Since all of these are consoles, we should definitely focus on making our action and sports games for a console. 

--To be 100% positive focusing on consoles is the best strategy, lets look the market share of each platform.

SELECT Platform, SUM(Global_Sales) AS Total_Sales, 
       SUM(Global_Sales) / (SELECT SUM(Global_Sales) FROM VideoGameData) AS Market_Share
FROM VideoGameData
GROUP BY Platform
ORDER BY Total_Sales DESC;

--PS2, X360, PS3, Wii, DS are the top 5 with the consoles taking up 44% of the market without counting the other consoles below that threshold.

--Based off my research, our company devs should focus on making an action or sports game, or combination. 
--Our front and back end developers should make a deliverable for a console. 
--Our marketing team should preapre to launch this game in the NA region for the best results. 
--Our sales team and marketing team should focus on previous Electronic Arts and Nintendo action/sports game sales campiagn to start developing our own plan.
--Now lets move to Tableau for some visualization 
