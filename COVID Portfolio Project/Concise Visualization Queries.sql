-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null and location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
--Group By date
order by 1,2


-- 2. 

-- European Union is part of Europe

Select location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by Location, Population, date
order by PercentPopulationInfected desc
