SELECT *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we'll be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
-- Shows the likelihood if you have covid in India
Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases)  as HighestInfectionCount,MAX( (total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing the countries with highest death count per population
Select Location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location  like '%India%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--breaking things down by continent
--Showing the continents with the highest death count
Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location  like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2

--total cases
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1,2

--Joining the 2 tables
Select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at total populations vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopvsVac (Continent, Location, Date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table
Drop table if exists  PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated

--Creating View to store datat for later visualizations
Create view PercentPopulationVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVac





