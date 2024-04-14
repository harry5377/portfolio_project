select * from Portfolio_project..CovidDeaths
where continent is not null
order by 3,4

--select * from Portfolio_project..Covidvaccination
--order by 3,4

--select data that we are going to be used

select location,date,total_cases,new_cases,total_deaths,population
from  Portfolio_project..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your coountry
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from  Portfolio_project..CovidDeaths
where location like '%myanmar' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as percentage_populationinfected
from Portfolio_project..CovidDeaths
where location like '%myanmar' and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select location,MAX(total_cases) as Highestinfectioncountry,
population,(Max(total_cases)/population)*100 as percentage_populationpercovid
from Portfolio_project..CovidDeaths
where continent is not null
group by location,population 
order by percentage_populationpercovid desc

--showing countries with highest death count per population
select location,Max(cast(total_deaths as int)) as total_deathcount
from Portfolio_project..CovidDeaths
where continent is not null
group by location
order by total_deathcount desc

--let's break things down by continent
--showing continent with highest death count per population
select location,Max(cast(total_deaths as int)) as total_deathcount
from Portfolio_project..CovidDeaths
where continent is null
group by location
order by total_deathcount desc

--Global Numbers
select sum(new_cases) as totalnewcases,
sum(cast(new_deaths as int)) as totalnewdeaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Deathpercentage
from Portfolio_project..CovidDeaths
where continent is not null

--looking at total popoulation vs vaccination 
select death.continent,death.location,death.date,death.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as Rollingpeoplevaccinated
from Portfolio_project..CovidDeaths as death
Join Portfolio_project..Covidvaccination as vac
on death.date=vac.date and death.location=vac.location
where death.continent is not null 
order by 2,3

--Using CTEs
With popvsvac(continent,location,date,population,new_vaccination$,Rollingpeoplevaccinated)
As 
(select death.continent,death.location,death.date,death.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as Rollingpeoplevaccinated
from Portfolio_project..CovidDeaths as death
Join Portfolio_project..Covidvaccination as vac
on death.date=vac.date and death.location=vac.location
where death.continent is not null 
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100 as percent_peoplevaccinated from popvsvac

--Using temp Table
Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccination numeric,
 Rollingpeoplevaccinated numeric)
insert #percentpopulationvaccinated 
select death.continent,death.location,death.date,death.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as Rollingpeoplevaccinated
from Portfolio_project..CovidDeaths as death
Join Portfolio_project..Covidvaccination as vac
on death.date=vac.date and death.location=vac.location
where death.continent is not null 
--order by 2,3

select *,(Rollingpeoplevaccinated/population)*100 as percent_pepolegotvaccine
from #percentpopulationvaccinated

--Creating view to store data for later visualization

Create view peoplevaccinatedview as 
select death.continent,death.location,death.date,death.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as Rollingpeoplevaccinated
from Portfolio_project..CovidDeaths as death
Join Portfolio_project..Covidvaccination as vac
on death.date=vac.date and death.location=vac.location
where death.continent is not null 

select * from peoplevaccinatedview