select *
FROM PortfolioProject.dbo.covidDeath
where continent is not null
order by 3,4

--select *
--FROM PortfolioProject.dbo.covidVacination
--order by 3,4

-- select Data that we are going to be using 

select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject.dbo.covidDeath
order by 1,2

-- looking at Total Cases VS Total Deaths 

select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.dbo.covidDeath
WHERE location LIKE '%Tunisia%' 
order by 1,2

-- Looking at Total Cases VS Population
-- show what percentage of population got covid 
select 
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 AS Deathpercentage
FROM PortfolioProject.dbo.covidDeath
WHERE location LIKE '%Tunisia%' 
order by 1,2 

-- looking at countries with Highest Infection Rate compared to population

select 
	location,
	population,
	Max(total_cases) As HighestInfectionCount,
	Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.covidDeath
--WHERE location LIKE '%Tunisia%' 
Group by location,population
order by PercentPopulationInfected desc

-- showing countries with Highest Death Count per Population
select 
	location,
	Max(cast(total_deaths As int)) As TotalDeath
	
FROM PortfolioProject.dbo.covidDeath
--WHERE location LIKE '%Tunisia%' 
where continent is null
Group by location,population
order by TotalDeath desc

-- Let's Break  things down by continent 
select 
	continent,
	Max(cast(total_deaths As int)) As TotalDeath
	
FROM PortfolioProject.dbo.covidDeath
--WHERE location LIKE '%Tunisia%' 
where continent is not null
Group by continent
order by TotalDeath desc

-- showing continents with the highest death count per population 

select 
	continent,
	Max(cast(total_deaths As int)) As TotalDeath

	
FROM PortfolioProject.dbo.covidDeath
--WHERE location LIKE '%Tunisia%' 
where continent is not null
Group by continent
order by TotalDeath desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.covidDeath
--WHERE location LIKE '%Tunisia%' 
where continent is not null 
--Group By date
order by 1,2

-- looking at Total Population vs Vacination

select dea.continent,dea.location,dea.date,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

from PortfolioProject.dbo.covidDeath dea
JOIN   PortfolioProject.dbo.covidVacination vac
 ON dea.location= vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3

 
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.covidDeath dea
Join PortfolioProject.dbo.covidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.covidDeath dea
Join PortfolioProject.dbo.covidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.covidDeath dea
Join PortfolioProject.dbo.covidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
