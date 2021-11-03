/* Queries for Tableau Visualizations */


/*#1: Global Covid cases, deaths, and percentange query */

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQL_COVID19_EDA..Covid_Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


/* #2: Total Covid deaths by continent query */

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From SQL_COVID19_EDA..Covid_Deaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

/* #3: Total Covid cases by country w % query */

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From SQL_COVID19_EDA..Covid_Deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

/* #4 Total Covid cases for each country by date w % query */

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From SQL_COVID19_EDA..Covid_Deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc