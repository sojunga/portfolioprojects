

select *
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
order by 3,4

--select data that weare going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from PORTFOLIOPROJECT..CovidDeaths$
order by 1,2


--looking at total cases vs total deaths 
--shows the posibility of dying if contracted covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PORTFOLIOPROJECT..CovidDeaths$
where location like '%states%'
where continent is not null
order by 1,2

--looking at total cases vs population 
--shows what percentage of the population got covid 

select location, date, total_cases, population, (total_cases/population)*100 as populatopninfectedpercent
from PORTFOLIOPROJECT..CovidDeaths$
where location like '%states%'
where continent is not null
order by 1,2

--countries with hisghest infection rate to poulation 

select location, population,max (total_cases) as highestinfectioncount, max((total_cases/population))*100 as populationinfectedpercent
from PORTFOLIOPROJECT..CovidDeaths$
group by location, population
order by populationinfectedpercent desc

--showing countries with highest death count per population 

select location,max(cast(total_deaths as int)) as totaldeathcount
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

--break things down by continent 
--showing th continets with the highest death count  per population 

select location, max(cast(total_deaths as int)) as totaldeathcount
from PORTFOLIOPROJECT..CovidDeaths$
where continent is null
group by location
order by totaldeathcount desc

--Global Numbers per day 

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int )) as totaldeaths, sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathpercent
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
group by date 
order by 1,2

--Global numbers Total cases

select sum(new_cases) as totalcases, sum(cast(new_deaths as int )) as totaldeaths, sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathpercent
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
--group by date 
order by 1,2

-- looking at total population vs vaccinations
--using a cte
with popvsvac (continent, locaion, date, population,new_vaccinations, rollingcountpplvac) 
as
(
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as rollingcountpplvac
from PORTFOLIOPROJECT..Covidvacs vac
join PORTFOLIOPROJECT..CovidDeaths$ dea
    on  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select *, (rollingcountpplvac/population)*100
from popvsvac

--temp table vers 
drop table if exists #pecenntpoplationvac
Create table #pecenntpoplationvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingcountpplvac numeric
)

insert into #pecenntpoplationvac
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as rollingcountpplvac
from PORTFOLIOPROJECT..Covidvacs vac
join PORTFOLIOPROJECT..CovidDeaths$ dea
    on  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

select *, (rollingcountpplvac/population)*100
from #pecenntpoplationvac

-- creating view for later visualizations 

CREATE OR ALTER VIEW percentpopulationvac AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, dea.date
    ) AS rollingcountpplvac
FROM
    PORTFOLIOPROJECT..Covidvacs vac
JOIN
    PORTFOLIOPROJECT..CovidDeaths$ dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

select *
from percentpopulationvac










