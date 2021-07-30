Select * 
From dbo.CovidDeaths
where continent is not Null
Order by 3,4

--Select * 
--From dbo.CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths, population
From dbo.CovidDeaths
where continent is not Null
Order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From dbo.CovidDeaths
where location like'%states%'
and continent is not Null
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location,date,total_cases,Population, (total_cases/population)* 100 as PercentPopulationInfected
From dbo.CovidDeaths
where location like'%states%'
Order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location,Population, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))* 100 as PercentPopulationInfected
From dbo.CovidDeaths
--where location like'%states%'
Group by Location,Population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--where location like'%states%'
where continent is not Null
Group by Location
Order by TotalDeathCount desc


-- LET"S BRREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--where location like'%states%'
where continent is not Null
Group by continent
Order by TotalDeathCount desc




--GLOBAL NUMBERS
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dbo.CovidDeaths
--where location like'%states%'
where continent is not Null
--group by date
Order by 1,2


--Looking at Total population vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not Null
order by 2,3

--USE CTE

with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not Null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From  PopvsVac


--TEMP TABLE

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
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not Null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not Null
--order by 2,3


Select *
From PercentPopulationVaccinated