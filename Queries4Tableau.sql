-- QUERIES USED FOR TABLEAU --



-- 1. Total Cases vs Total Deaths

SELECT SUM(New_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 1,2



-- 2. Death Count by Location
-- Keeping data consistent by removing duplicates from world, european union, and international

SELECT Location, SUM(cast(new_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE  Continent is NULL and location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC



-- 3. Percent Population Infected by location

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC

-- Used CTE and removed NULL values with 'COALESCE'
WITH PercentPopInfected (Location, Population, HighestInfectionCount, PercentPopulationInfected)
AS
(
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, Population
)
SELECT Location, COALESCE(Population, 0) AS Population, COALESCE(HighestInfectionCount, 0) AS HighestInfectionCount, COALESCE(PercentPopulationInfected, 0) AS PercentPopulationInfected
FROM PercentPopInfected
ORDER BY PercentPopulationInfected DESC



-- 4. Percent Population Infected by location , date

SELECT Location, Population, Date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, Population, Date
ORDER BY PercentPopulationInfected DESC

-- Used CTE and removed NULL values with 'COALESCE'
WITH PercentPopInfected (Location, Population, Date, HighestInfectionCount, PercentPopulationInfected)
AS
(
SELECT Location, Population, Date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, Population, Date
--ORDER BY PercentPopulationInfected DESC
)
SELECT Location, COALESCE(Population, 0) AS Population, Date, COALESCE(HighestInfectionCount, 0) AS HighestInfectionCount, COALESCE(PercentPopulationInfected, 0) AS PercentPopulationInfected
FROM PercentPopInfected
ORDER BY PercentPopulationInfected DESC