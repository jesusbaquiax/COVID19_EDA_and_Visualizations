SELECT *
FROM SQL_COVID19_EDA..Covid_Deaths;

SELECT *
FROM SQL_COVID19_EDA..Covid_Vaccinations;


-- Select Data to analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_COVID19_EDA..Covid_Deaths
ORDER BY 1, 2;

-- Total Cases VS Total Deaths Percentage by Date filtered by Country

SELECT location, 
		date, 
		total_cases, 
		total_deaths, 
		ROUND(((total_deaths/total_cases) * 100),2) AS Death_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
AND LOCATION = 'United States'
ORDER BY 1, 2;

-- Total Cases VS Population Percentage by Date Filtered by Country

SELECT location, 
		date, 
		total_cases, 
		population, 
		ROUND(((total_cases/population) * 100),2) AS Covid_Pop_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
WHERE LOCATION = 'United States'
ORDER BY 1, 2;


-- Highest Infection VS Population Rates by Country

SELECT location, 
		population,
		MAX(total_cases) AS Highest_Infection_Count, 
		ROUND(((MAX(total_cases/population)) * 100),2) AS Infection_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infection_Percentage DESC;


-- Highest Death Rates by Country

SELECT location, 
		MAX(cast(total_deaths as int)) AS Total_Deaths
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Deaths DESC;


-- Highest Death Rates by Continent

SELECT continent, 
		MAX(cast(total_deaths as int)) AS Total_Deaths
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Deaths DESC;

-- Another table for Highest Death Rates by Continent
-- shows discrepancy
SELECT location, 
		MAX(cast(total_deaths as int)) AS Total_Deaths
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is null
GROUP BY location
ORDER BY Total_Deaths DESC;


-- Global Cases VS Deaths Percentage by Day

SELECT  date, 
		SUM(new_cases) AS Total_Cases, 
		SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
		ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS Death_Percentage
FROM SQL_COVID19_EDA..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2;


-- Global Population VS Vaccination (at least one) by Day with Rolling Count

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
)
SELECT *, (Num_People_Vaccinated/Population)*100 AS Percentage_Vaccinated
FROM PopvsVac;

-- View fot data visualizations

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