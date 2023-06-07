select *
from PorfolioProjects..covid_death
order by 3,4

-- Select data
select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProjects..covid_death
where continent is not null
order by 1,2

-- Change the datatype
alter table PorfolioProjects..covid_death
alter column total_cases float
alter table PorfolioProjects..covid_death
alter column total_deaths Int


-- Looking at total cases vs total deaths
-- Death rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate_Percent
from PorfolioProjects..covid_death
where location like '%China%'
order by 1,2

-- Looking at total cases vs population
-- Likelyhood to get covid
select location, date, total_cases, population, (total_cases/population)*100 as CovidRate_Percent
from PorfolioProjects..covid_death
where location like '%China%'
order by 1,2

-- Find  countries with highest infection rate
select location, population, max(total_cases) as Infections, Max((total_cases/population)*100) as CovidRate_Percent
from PorfolioProjects..covid_death
where continent is not null
group by location, population
order by 4 desc

-- Find countries with highest death count over covid
select location, max(total_deaths) as TotalDeaths
from PorfolioProjects..covid_death
where continent is not null
group by location
order by 2 desc

-- Looking up the deaths in each continent

--select location, max(total_deaths) as TotalDeaths
--from PorfolioProjects..covid_death
--where continent is null
--and location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income', 'European Union')
--group by location
--order by 2 desc

select continent, max(total_deaths) as TotalDeaths
from PorfolioProjects..covid_death
where continent is not null
group by continent
order by 2 desc

--Global numbers
select date, sum(cast(new_deaths as int)) as NewDeaths, sum(new_cases) as NewCases,
       isnull(sum(cast(new_deaths as int)) / nullif(sum(new_cases), 0) * 100, 0) as DeathPercentage --eliminate items returned that has sum(new_cases) as 0 which give an error
from PorfolioProjects..covid_death
where continent is not null
group by date
order by 1,2;

-- Global sum
select sum(cast(new_deaths as int)) as TotalDeaths, sum(new_cases) as TotalCases,
       isnull(sum(cast(new_deaths as int)) / nullif(sum(new_cases), 0) * 100, 0) as DeathPercentage --eliminate items returned that has sum(new_cases) as 0 which give an error
from PorfolioProjects..covid_death
where continent is not null
order by 1,2;

-- Using the table covid_vax
select *
from PorfolioProjects..covid_vax
order by 3,4

-- Join two tables
select *
from PorfolioProjects..covid_death cd
join PorfolioProjects..covid_vax cv
on cd.location = cv.location and cd.date = cv.date


-- Looking at total population vs vaccinations
with VacOPop (continent, location, date, population, new_vaccinations_smoothed, RollingVaccination)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations_smoothed,
sum(convert(float,cv.new_vaccinations_smoothed)) over (partition by cd.location order by cd.location,cd.date) as RollingVaccination
from PorfolioProjects..covid_death cd
join PorfolioProjects..covid_vax cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
)
select *, RollingVaccination/population*100 as VaxPercentage
from VacOPop
order by 2,3

-- Creating view for visualization

--drop view if exists VaxPercentage

create view VaxPercentage
as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations_smoothed,
sum(convert(float,cv.new_vaccinations_smoothed)) over (partition by cd.location order by cd.location,cd.date) as RollingVaccination
from PorfolioProjects..covid_death cd
join PorfolioProjects..covid_vax cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null