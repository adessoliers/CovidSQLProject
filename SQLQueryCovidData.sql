SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4


-- Select Data that we are going to use
SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Identifying percent of death over time 
SELECT Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2


--  Total Cases vs Population
-- Identifying percent of population got covid
SELECT Location, Date, Population, Total_cases, (Total_cases/Population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2


-- Looking at Highest Infection Rate compared to Population by Country
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

 
-- Countries with Highest Death Count per Population
-- Set "total_deaths" from varchar to INT using *cast(column as INT)*
-- Dataset contains null values in continent. Adding  'where continent is NOT NULL' to pull in countries
SELECT Location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE Continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- Continents with Highest Death Count per Population
SELECT Continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE Continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- Worldwide Death Percentage in Total
SELECT SUM(New_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 1,2

-- Worldwide Death Percentage by day
SELECT Date, SUM(New_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(New_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Continent is NOT NULL
GROUP BY Date
ORDER BY 1,2

-------------------------------------------------------------

--Joining CovidDeaths & CovidVaccinations tables by location & date
SELECT *
FROM CovidProject..CovidDeaths Dea
JOIN CovidProject..CovidVaccinations Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE Dea.Continent is NOT NULL


-- Total Population vs Vaccinations
-- Identifying how soon the vaccinations were rolled out in each country
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent is NOT NULL
ORDER BY 2,3


-- Modified Total Population vs Vaccination
-- Utilizing 'Partition by' to create column 'RollingPeopleVaccinated'
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent is NOT NULL
ORDER BY 2,3



-- USING CTE
-- Identifying percentage of population vaccinated over time
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
FROM PopvsVac
ORDER BY 2,3



-- Creating TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3



-- Creating VIEW to store data for visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


