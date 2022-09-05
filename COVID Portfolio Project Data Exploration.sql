SELECT *
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in each country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population that got infected with covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 1,2



--Looking at Countries with highest infection rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group By location, population
Order By PopulationInfectedPercentage DESC



--Showing the Countries with highest death count per population

Select Location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group By location 
Order By TotalDeathCount DESC



-- BROKEN DOWN BY CONTINENT

--Showing the continent with highest death count

Select continent, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Group By continent
Order By TotalDeathCount DESC



--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
Order By 1,2



--Looking at Total Population vs Vaccinations
--This shows the percentage of the population that has received at least one vaccine for Covid


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location,
dea.date) as Rolling_Total_Vaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL AND dea.location NOT LIKE 'income'
Order By 2,3


--Using CTE to perform the same calculation on Partition By as the previous query

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
)
Select *, (Rolling_Total_Vaccinated/Population)*100 as Rolling_Total_Vaccinated_Percentage
From PopvsVac



--Using Temp Table to perform the same calculation on Partition By as the previous query.

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
Where dea.continent IS NOT NULL AND dea.location NOT LIKE 'income'


Select *
From PercentPopulationVaccinated
