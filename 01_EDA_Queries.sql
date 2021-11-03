/* COVID 19 Explorative Data Analysis as of 10/31/2021 */

-- Inspect excel files that will be used

-- Covid_Deaths Table

SELECT *
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
ORDER BY 3,4;


-- Covid_Vaccinations Table

SELECT *
FROM SQL_COVID19_EDA..Covid_Vaccinations
WHERE continent is not null
ORDER BY 3,4;


-- Selecting Data for Analysis

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
ORDER BY 1, 2;


/* Total Cases VS Population Percentage by Date Filtered by Country:
13.81% of the U.S. population has been diagnosed with Covid. */

SELECT location, 
		date, 
		total_cases, 
		population, 
		ROUND(((total_cases/population) * 100),2) AS Covid_Pop_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
AND LOCATION = 'United States'
ORDER BY 1, 2;


/* Total Cases VS Total Deaths Percentage by Date filtered by Country:
1.62% of all Covid cases resulted in a death in the United States. 
While Covid has had a grave cost of life, the percent of cases and deaths are still small.
*/

SELECT location, 
		date, 
		total_cases, 
		total_deaths, 
		ROUND(((total_deaths/total_cases) * 100),2) AS Death_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
AND LOCATION = 'United States'
ORDER BY 1, 2;


/* Highest Infection VS Population Rates by Country:
The United States ranks 15th for infection percentages compared to other countries.
The combined populations of the countries ranked 1st thru 14th is smaller than the United States. */

SELECT location, 
		population,
		MAX(total_cases) AS Highest_Infection_Count, 
		ROUND(((MAX(total_cases/population)) * 100),2) AS Infection_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infection_Percentage DESC;


/* Highest Death Rates by Country:
The United States has the highest count of Covid deaths followed by Brazil, India, Mexico, and Russia.
The percent of deaths is still relatively small compared to each country's population. */

SELECT location, 
		MAX(cast(total_deaths as int)) AS Total_Deaths
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Deaths DESC;


/* Highest Death Rates by Continent:
North America, South America, Asia, Europe, Africa, Oceania */

SELECT continent, 
		MAX(cast(total_deaths as int)) AS Total_Deaths
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Deaths DESC;


/* Global Cases VS Deaths Percentage by Day:
1.44% of all the Global Covid cases resulted in death.*/

SELECT  date, 
		SUM(new_cases) AS Total_Cases, 
		SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
		ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS Death_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2;


/* Global Population VS Vaccination (at least one shot) by Day with Rolling Count */

SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) 
		OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Num_People_Vaccinated
FROM SQL_COVID19_EDA..Covid_Deaths AS dea
JOIN SQL_COVID19_EDA..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
order by 2,3;



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Num_People_Vaccinated)
AS
(
SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) 
		OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Num_People_Vaccinated
FROM SQL_COVID19_EDA..Covid_Deaths AS dea
JOIN SQL_COVID19_EDA..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
)
SELECT *, (Num_People_Vaccinated/Population)*100 AS Percentage_Vaccinated
FROM PopvsVac;

-- Creating View fot data visualizations

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) 
		OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Num_People_Vaccinated
FROM SQL_COVID19_EDA..Covid_Deaths AS dea
JOIN SQL_COVID19_EDA..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null