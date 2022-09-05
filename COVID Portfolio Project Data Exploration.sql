SELECT *
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 3,4


--Select Data that we are going to be using

Select continent, Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 2,3


--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 2,3


--Looking at Total Cases vs Total Deaths
--Shows what percentage of population that got covid

Select continent, Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 2,3



--Looking at Countries with highest infection rate compared to Population

Select continent, Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group By continent, location, population
Order By PopulationInfectedPercentage DESC



--Showing the Countries with highest death count 

Select continent, Location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group By continent, location 
Order By TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continent with highest death count
Select location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
Group By location
Order By TotalDeathCount DESC



--GLOBAL NUMBERS

--By day
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group By  date
Order By 1,2

--Total Global
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 1,2


--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location,
dea.date) as Rolling_Total_Vaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
Order By 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location,
dea.date) as Rolling_Total_Vaccinated

From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
--Order By 2,3
)
Select *, (Rolling_Total_Vaccinated/Population)*100 as Rolling_Total_Vaccinated_Percentage
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
Rolling_Total_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location,
dea.date) as Rolling_Total_Vaccinated

From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent IS NOT NULL
--Order By 2,3

Select *, (Rolling_Total_Vaccinated/Population)*100 as Rolling_Total_Vaccinated_Percentage
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location,
dea.date) as Rolling_Total_Vaccinated

From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL


Select *
From PercentPopulationVaccinated
