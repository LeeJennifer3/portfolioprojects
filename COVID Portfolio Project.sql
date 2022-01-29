SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data to be used

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null -- To remove lines where data refers to the entire continent, not country
ORDER BY 2,3


-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of death if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,4) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs. Total Population Per Country
-- Shows Percentage of Population Infected with COVID

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,4) AS case_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count -- convert total deaths column from string to integer
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Viz 1. Looking at Percentage of Total Deaths as a whole

SELECT 
	SUM(new_cases) AS Total_Cases, 
	sum(cast(new_deaths as int)) AS Total_Deaths, 
	ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,4) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Viz 2. Showing continents with highest death count per population 

SELECT continent, SUM(CAST(new_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Viz 3. Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, ROUND(MAX(total_cases/population)*100,4) AS Infection_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC


-- Viz 4. Looking at infection rates per country per day compared to population

SELECT location, population, date, MAX(total_cases) AS Highest_Infection_Count, ROUND(MAX(total_cases/population)*100,4) AS Infection_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY 4 DESC


-- Looking at Percentage of Total Deaths Per Date (Global)

SELECT 
	date, 
	SUM(new_cases) AS Total_Cases, 
	sum(cast(new_deaths as int)) AS Total_Deaths, 
	ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,4) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs. Rolling Vaccination Totals

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE to perform calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vaccinations)
AS (
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT *, ROUND((Rolling_Total_Vaccinations/Population)*100,4) AS Percentage_Vaccinated
FROM PopvsVac


-- Create Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Total_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *, (Rolling_Total_Vaccinations/Population)*100 AS Percentage_Vaccinated
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null

-- Check that view was created correctly

SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2,3

