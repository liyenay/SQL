select *
from CovidDeathsss
where continent is not null
order by 3,4

-- select *
-- from CovidVaccinations
-- order by 3,4

-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeathsss
order by 1,2

-- Looking at the Total Case vs Total Deaths

WITH case_death AS (select Location, date, total_cases+0.000 as total_cases, total_deaths+0.000 as total_deaths
from CovidDeathsss)

select *, round((total_deaths/total_cases)*100,3) as DeathPerc
from case_death
where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

WITH case_pop AS (select Location, date, total_cases+0.00 as total_cases, population
from CovidDeathsss)

select *, (total_cases/population)*100 as CasesPerc
from case_pop
where Location like '%states%'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

select Location, population, max(total_cases+0.00) as HighestInfectionCount, max(((total_cases+0.00)/population)*100) as PercPopulationInfected
from CovidDeathsss
group by Location, Population
order by PercPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeathsss
where continent is not null
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THIS DOWN BY CONTINENT

select continent, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeathsss
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population (same as above)

select continent, max(total_deaths) as TotalDeathCount
from CovidDeathsss
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

WITH case_death AS (select continent, Location, date, total_cases+0.000 as total_cases, total_deaths+0.000 as total_deaths
from CovidDeathsss)

select *, (total_deaths/total_cases)*100 as DeathPerc 
from case_death
where continent is not null
order by 1,2

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast (new_cases as float))*100 as DeathPerc
from CovidDeathsss
where continent is not null
group by [date]
order by 1,2


-- Looking at Total Population vs Populations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,
    dea.date) as RolllingPeopleVacc
from CovidDeathsss as dea
JOIN CovidVaccinations as vac
    on dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not NULL and vac.new_vaccinations is not NULL
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RolllingPeopleVacc)
AS (

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,
    dea.date) as RolllingPeopleVacc
from CovidDeathsss as dea
JOIN CovidVaccinations as vac
    on dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not NULL and vac.new_vaccinations is not NULL
-- order by 2,3
)

select *, (cast(RolllingPeopleVacc as float) /Population)*100
from PopvsVac




-- Temp table

create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacc numeric
)
insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,
    dea.date) as RolllingPeopleVacc
from CovidDeathsss as dea
JOIN CovidVaccinations as vac
    on dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not NULL and vac.new_vaccinations is not NULL

select *, (cast(RollingPeopleVacc as float) /Population)*100 as PercPeoplVacc
from #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,
    dea.date) as RolllingPeopleVacc
from CovidDeathsss as dea
JOIN CovidVaccinations as vac
    on dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not NULL and vac.new_vaccinations is not NULL

select *
from PercentPopulationVaccinated
