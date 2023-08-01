SELECT*
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT*
--FROM Portfolio..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location like'%canada%'
ORDER BY 1,2

-- Total Cases vs Population

SELECT location, date, total_cases, population,(total_cases/population) AS PercentPopulationInfected
FROM Portfolio..CovidDeaths
WHERE location like'%canada%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases)AS HighestInfectionCount , MAX((total_cases/population)) AS PercentPopulationInfected
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths AS INT) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date, SUM(new_cases)as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,SUM(CAST(new_deaths as int))
/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total Vaccinations vs Population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY dea.
location ORDER BY dea.location, dea.date) AS RolledVaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH Popvsvac (continent, location, date, population,new_vaccinations,RolledVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY dea.
location ORDER BY dea.location, dea.date) AS RolledVaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *,(RolledVaccinated/population)*100
FROM Popvsvac

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RolledVaccinated numeric 
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY 
dea.location ORDER BY dea.location, dea.date) AS RolledVaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RolledVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store date for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY 
dea.location ORDER BY dea.location, dea.date) AS RolledVaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT*
FROM PercentPopulationVaccinated
