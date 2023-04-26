
--running both data to ensure correct files are selected

 select * from [Covid19_project].[dbo].[Covid_Deaths]
  select * from [Covid19_project].[dbo].[Covid_Vaccinations]

 --reviewing some of the columns needed for the project
 select 
 location, 
 date,
 population,
 total_deaths, 
 new_cases, 
 total_cases,
 reproduction_rate,icu_patients
 from [Covid19_project].[dbo].[Covid_Deaths]

 --total_cases VS total_deaths, casted as floats total_deaths and total_cases for division
 --use case when to correct the  divided by zero errors
 select 
 location,
 date,
 population,
 total_cases,
 total_deaths,
 case 
 when cast (total_deaths as float) =  0 then null
 when cast (total_cases as float) =  0    then null
 else cast(total_deaths as float)/ cast(total_cases  as float)*100 END as Percent_deaths_vs_totalcases

 from [Covid19_project].[dbo].[Covid_Deaths]
where location like '%canada%'
order by 1,2

--Total_cases Vs Population
-- this shows the percentage of people who have contracted Covid19 from 2020 till date
select 
 location,
 date,
 population,
 total_cases,
 case 
 when cast (total_cases as float) =  0 then null
 when cast (population as float) =  0    then null
 else round(cast(total_cases as float)/ cast(population  as float)*100,2) END as Percent_cases_vs_population
 from [Covid19_project].[dbo].[Covid_Deaths]
--where location like '%canada%'
order by 1,2

-- countries with the Highest Infection rate

select
 location,
 population,
 max(cast(total_cases as float)) as InfectionCount,
 case 
 when max(cast (total_cases as float)) =  0 then null
 when cast (population as float) =  0    then null
 else max(round(cast(total_cases as float)/ cast(population  as float)*100,2)) END as InfectionRate
 from [Covid19_project].[dbo].[Covid_Deaths]
where location like '%canada%'
group by location,population
order by InfectionRate desc

--checking for total country count
select distinct (location)
from [Covid19_project].[dbo].[Covid_Deaths]

-- countrires with the highest death toll
select
 location,
 population,
 max(cast(total_deaths as float)) as DeathToll,
 case 
 when max(cast (total_deaths as float)) =  0 then null
 when cast (population as float) =  0    then null
 else max(round(cast(total_deaths as float)/ cast(population  as float)*100,2)) END as DeathRate
 from [Covid19_project].[dbo].[Covid_Deaths]
where location like '%canada%'
group by location,population
order by DeathRate desc

---continent with the highest death toll using <> space to filter the continents
select
continent, 
 max(cast(total_deaths as float)) as DeathTollContinent,
 case 
 when max(cast (total_deaths as float)) =  0 then null
 when max(cast(population as float)) =  0    then null
 else max(round(cast(total_deaths as float)/ cast(population  as float)*100,2)) END as DeathRateContinent
 from [Covid19_project].[dbo].[Covid_Deaths]
where continent <> ' ' 
group by continent
order by DeathRateContinent desc

select distinct continent, location from Covid19_project.dbo.Covid_Deaths

--Global numbers
--checking for population growth through childbirth
select datepart(year,date) as dateyear,
 
sum(cast( reproduction_rate as float))as Birthrate,
sum(cast(total_deaths as float)) as Deathrate,
case
when sum(cast( reproduction_rate as float))= 0 then Null
when sum(cast( total_deaths as float)) = 0 then Null 
else round(sum(cast( reproduction_rate as float))/sum(cast(total_deaths as float)),5) * 100  end
from Covid19_project.dbo.Covid_Deaths
--where continent <> ' '
where location like'%canada%'
Group by date

--checking for new cases, ICu admissions and new deaths in canada since 2023
select  datename(MONTH,date) as dateyear,
sum(cast(icu_patients as float)) as new_icu_patients,
sum(cast(weekly_icu_admissions as float)) as Icu_admissions,
 
sum(cast( new_cases as float))as new_case,
sum(cast(new_deaths as float)) as newDeathrate,
case
when sum(cast( new_cases as float))= 0 then Null
when sum(cast( new_deaths as float)) = 0 then Null 
else round(sum(cast( new_cases as float))/sum(cast(new_deaths as float)),5) * 100  end as new_casespercentage
from Covid19_project.dbo.Covid_Deaths
--where continent <> ' '
where location like'%canada%' and date >= '2023'
Group by location, date

-- Total people Vaccinated as at 2023

select 
Dea.location,
Dea.Population, 
Dea.date, 
Vac.total_vaccinations 
from Covid19_project.dbo.Covid_Deaths as Dea
left join 
 Covid19_project.dbo.Covid_Vaccinations as Vac  
 on Dea.location = Vac.location and Dea.date = Vac.date
 where dea.date >= 2023



-- new people Vaccinated as at 2023
with PopVac as 
(
select distinct
Dea.location as Locale,
Dea.date,
sum(cast (Dea.Population as float)) as Populatn, 
 sum(cast(Vac.new_vaccinations as float))   as rolledoutvacs
from Covid19_project.dbo.Covid_Deaths as Dea
left join 
 Covid19_project.dbo.Covid_Vaccinations as Vac  on Dea.location = Vac.location and Dea.date = Vac.date
 where dea.continent  <> ' ' and dea.date >= '2023'
 group by dea.continent, dea.location,Dea.date
 )
 select *,round((rolledoutvacs/Populatn)*100,2) as newlyroledoutpercentage
 from PopVac
 where Locale like '%Canada%'
 
-- checking for total vaccinated, boosters, cases population in canada
with PopVac as 
(
select distinct
Dea.location,
sum(cast (Dea.Population as float)) as Populationsize, 
sum(cast(dea.total_cases as float)) as totalcases,
 sum(cast(Vac.total_vaccinations as float))   as totalrolledoutvacs,
 sum(cast(vac.total_boosters as float)) as Boosteraftervacs,
 sum(cast(dea.total_deaths as float)) as Deaths
from Covid19_project.dbo.Covid_Deaths as Dea
left join 
 Covid19_project.dbo.Covid_Vaccinations as Vac  on Dea.location = Vac.location and Dea.date = Vac.date
 where dea.continent  <> ' ' 
 group by dea.continent, dea.location,Dea.date
)
 Select 
 round((totalcases/populationsize)*100, 2) as Cases,
 round((totalrolledoutvacs/Populationsize)*100,2) as Vaccines,
 round((Boosteraftervacs/populationsize)*100,2) as Boosters
 from PopVac
where location = '%canada%'

--Temp Table
Create Table #Covid19Dataset
( continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
rolledoutvacs numeric)

 insert into #Covid19Dataset
 select distinct
 dea.Continent,
Dea.location,
Dea.date,
sum(cast (Dea.Population as float)) as Populatn, 
 sum(cast(Vac.new_vaccinations as float))   as rolledoutvacs
from Covid19_project.dbo.Covid_Deaths as Dea
left join 
 Covid19_project.dbo.Covid_Vaccinations as Vac  on Dea.location = Vac.location and Dea.date = Vac.date
 where dea.continent  <> ' ' 
 group by dea.continent, dea.location,Dea.date

  select 
  (rolledoutvacs/Population)*100 as rolledoutpercentage
  from  #Covid19Dataset

 
 /*creating a view to see the population with certain diseases*/
 Create View Covidailments AS
 Select distinct dea.location,
 Vac.female_smokers, 
 Vac.male_smokers,
 vac.cardiovasc_death_rate,
 vac.diabetes_prevalence
 from Covid19_project.dbo.Covid_Deaths as Dea
 left join 
 Covid19_project.dbo.Covid_Vaccinations as Vac 
 on Dea.location = Vac.location and Dea.date = Vac.date
 where dea.continent  <> ' ' 
 

