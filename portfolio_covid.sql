--creating a new database for sql queries in azure data studio for mac, really not straightforward for mac users  

USE master;
GO

IF NOT EXISTS (
      SELECT name
      FROM sys.databases
      WHERE name = N'PortfolioProject'
      )
   CREATE DATABASE [PortfolioProject];
GO

IF SERVERPROPERTY('ProductVersion') > '12'
   ALTER DATABASE [PortfolioProject] SET QUERY_STORE = ON;
GO

--testing if the tables and the database work
select *
from PortfolioProject..[covidvaccinations]
order by 3,4

--selecting data to be used
select location,date,total_cases,new_cases,total_deaths
from PortfolioProject..[coviddeaths]
order by 1,2


--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..[coviddeaths]
where location like '%india%'
order by 1,2

--looking at total cases vs population
select location,date,total_cases,population,(total_deaths/population)*100 as deathpercentage
from PortfolioProject..[coviddeaths]
where location like '%india%'
order by 1,2

--countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 as infectionpercent
from PortfolioProject..[coviddeaths]
--where location like '%state%'
Group by location, population
order by infectionpercent DESC

--number of people who died and the countries with the highest number
select location, MAX(total_deaths) as Totaldeathcount
from PortfolioProject..[coviddeaths]
--where location like '%state%'
where continent is not NULL
Group by location
order by Totaldeathcount DESC 

--breaking things by continent
--showing the continents with the highest death count
select continent, max(total_deaths) as Totaldeathcount
from PortfolioProject..[coviddeaths]--where location like '%state%'
where continent is not null
group by continent
order by totaldeathcount DESC

--global numbers

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
--where location like '%state%'
where continent is not null 
--group by date 
order by 1,2

--vaccinations
--total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
