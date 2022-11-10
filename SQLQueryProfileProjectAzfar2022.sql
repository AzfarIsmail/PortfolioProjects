SELECT *
FROM PortfolioProject..CovidDeaths2022
ORDER BY date,population

SELECT DISTINCT(Continent1)
FROM PortfolioProject..CovidDeaths2022

--What is the Total Cases vs Total Death Percentage ?
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Percentage_Of_Fatalities
FROM PortfolioProject..CovidDeaths2022
WHERE location like '%Malaysia%'
ORDER BY date ASC

-- What is the percentage of the population contracted COVID in Malaysia?
SELECT location,date,total_cases,population,(total_cases/population)*100 AS Percentage_Of_Infected_Population
FROM PortfolioProject..CovidDeaths2022 
WHERE location = 'Malaysia'
ORDER BY date ASC

--Which country have the Highest Infection Count vs Population?
SELECT location,MAX(total_cases) as Highest_Infection_Count,population,MAX((total_cases)/population)*100 AS Max_Percentage_Of_Infected_Population
FROM PortfolioProject..CovidDeaths2022
WHERE NOT (location = 'World' OR location = 'Lower middle income' or location = 'Low income' OR location = 'International' OR location='Upper middle income' OR location='High income' OR
location = 'Asia' OR location = 'Europe' OR location='North America' OR location='South America' OR location = 'Oceania' OR location='Africa' OR location = 'European Union')
GROUP BY location,population
ORDER BY Max_Percentage_Of_Infected_Population DESC

--Which country have the Highest Death Count?
SELECT location,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths2022
WHERE NOT (location = 'World' OR location = 'Lower middle income' or location = 'Low income' OR location = 'International' OR location='Upper middle income' OR location='High income' OR
location = 'Asia' OR location = 'Europe' OR location='North America' OR location='South America' OR location = 'Oceania' OR location='Africa' OR location = 'European Union')
GROUP BY location
ORDER BY Total_Death_Count DESC

--Which continent have the Highest Death Count?
SELECT Continent1,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths2022
WHERE NOT (location = 'World' OR location = 'Lower middle income' or location = 'Low income' OR location = 'International' OR location='Upper middle income' OR location='High income'OR location='European Union')
GROUP BY Continent1
ORDER BY Total_Death_Count DESC

SELECT date, new_cases,new_deaths
FROM PortfolioProject..CovidDeaths2022
WHERE location = 'World'
ORDER BY date ASC

-- What is the cumulative population that are vaccinated?
SELECT dea.Continent1, dea.location, dea.date, dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS Cumulative_Vaccination
FROM PortfolioProject..CovidDeaths2022 dea
JOIN PortfolioProject..CovidVaccinations2022 vac
	ON dea.location = vac.location
	AND dea.date =	vac.date
WHERE NOT (dea.location = 'World' OR dea.location = 'Lower middle income' or dea.location = 'Low income' OR dea.location = 'International' OR dea.location='Upper middle income' OR dea.location='High income' OR
dea.location = 'Asia' OR dea.location = 'Europe' OR dea.location='North America' OR dea.location='South America' OR dea.location = 'Oceania' OR dea.location='Africa' OR dea.location = 'European Union')

-- Trying CTE
With Pop_Vs_Vac (Continent1,location,date,population,new_vaccinations,Cumulative_Vaccination)
as 
(SELECT dea.Continent1, dea.location, dea.date, dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS Cumulative_Vaccination
FROM PortfolioProject..CovidDeaths2022 dea
JOIN PortfolioProject..CovidVaccinations2022 vac
	ON dea.location = vac.location
	AND dea.date =	vac.date
WHERE NOT (dea.location = 'World' OR dea.location = 'Lower middle income' or dea.location = 'Low income' OR dea.location = 'International' OR dea.location='Upper middle income' OR dea.location='High income' OR
dea.location = 'Asia' OR dea.location = 'Europe' OR dea.location='North America' OR dea.location='South America' OR dea.location = 'Oceania' OR dea.location='Africa' OR dea.location = 'European Union')
)
SELECT *, (Cumulative_Vaccination/population) *100 AS Cumulative_Percentage_Pop_Vaccinated
FROM Pop_Vs_Vac

-- Creating a Temporary Table
DROP TABLE IF EXISTS #PercentageofPopulationVaccinated
CREATE TABLE #PercentageofPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population bigint,
New_Vaccination numeric,
Cumulative_Vaccination bigint
)

INSERT INTO #PercentageofPopulationVaccinated
SELECT dea.Continent1, dea.location, dea.date, dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS Cumulative_Vaccination
FROM PortfolioProject..CovidDeaths2022 dea
JOIN PortfolioProject..CovidVaccinations2022 vac
	ON dea.location = vac.location
	AND dea.date =	vac.date
WHERE NOT (dea.location = 'World' OR dea.location = 'Lower middle income' or dea.location = 'Low income' OR dea.location = 'International' OR dea.location='Upper middle income' OR dea.location='High income' OR
dea.location = 'Asia' OR dea.location = 'Europe' OR dea.location='North America' OR dea.location='South America' OR dea.location = 'Oceania' OR dea.location='Africa' OR dea.location = 'European Union')

SELECT *, (Cumulative_Vaccination/Population)*100 AS Percentage_Vaccinated
FROM #PercentageofPopulationVaccinated

-- Creating View for Data Visualisation
CREATE VIEW PercentageofPopulationVaccinated AS
SELECT dea.Continent1, dea.location, dea.date, dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS Cumulative_Vaccination
FROM PortfolioProject..CovidDeaths2022 dea
JOIN PortfolioProject..CovidVaccinations2022 vac
	ON dea.location = vac.location
	AND dea.date =	vac.date
WHERE NOT (dea.location = 'World' OR dea.location = 'Lower middle income' or dea.location = 'Low income' OR dea.location = 'International' OR dea.location='Upper middle income' OR dea.location='High income' OR
dea.location = 'Asia' OR dea.location = 'Europe' OR dea.location='North America' OR dea.location='South America' OR dea.location = 'Oceania' OR dea.location='Africa' OR dea.location = 'European Union')

SELECT *
FROM PercentageofPopulationVaccinated