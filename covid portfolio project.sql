select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total Deaths
--shows likelihoood of dying if you contract covid in your country
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where location like'%india%'
order by 1,2

--looking at total cases vs population
--shows what percentage of poopulation got covid
select Location, date, population, total_cases,(total_deaths/population)*100 as PopulationInfected
From PortfolioProject..CovidDeaths
where location like'%india%'
order by 1,2

--looking at countries with higher infection rate compared to population
select Location, population, MAX(total_cases)as highestInfectionCount,MAX((total_cases/population))*100 as percentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
--where location like'%india%'
order by percentPopulationInfected desc


--lets break things by continent
select continent, MAX(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--


--showing the countries with highest death count per population
select Location, MAX(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- showing continents with the hihest death count per population 
select continent, MAX(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
--where location like'%india%'
where continent is not  null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUm(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--(RollingPeopleVaccinated/populattion)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3

--using cte
with PopvsVac(continent, Location, Date, Population, New_Vaccinations, RolligPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUm(cast(vac.new_vaccinations as int))over(partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVacinated
--(RollingPeopleVaccinated/populattion)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

)
select *, (RolligPeopleVaccinated/population)*100
From PopvsVac

--temp table
Drop Table if exists #percentpoulationVaccinated
create table #percentpoulationVaccinated(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RolligPeopleVaccinated  numeric)

Insert into #percentpoulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUm(cast(vac.new_vaccinations as int))over(partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVacinated
--(RollingPeopleVaccinated/populattion)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (RolligPeopleVaccinated/population)*100
From #percentpoulationVaccinated



--craeting view to store data for later visulaizations
create view percentpoulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUm(cast(vac.new_vaccinations as int))over(partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVacinated
--(RollingPeopleVaccinated/populattion)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
From percentpoulationVaccinated