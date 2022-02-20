-- 
-- 			---> EXPLORING THE COVID DATASET <---
-- 

-- Brief Overlook of `covid_deaths` df
SELECT 
	location, 
	DATE_FORMAT( STR_TO_DATE( date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, -- this converts DATE to a formate sql likes
    new_cases,
    total_cases, 
    new_deaths, 
    total_deaths, 
    population
FROM covid_deaths
ORDER BY location, date;


-- Brief OVERLOOK of `covid_vaccinations` df
SELECT 
	location, 
	DATE_FORMAT( STR_TO_DATE( date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date,
    new_tests, 
    total_tests, 
    new_vaccinations, 
    people_vaccinated, 
    people_fully_vaccinated, 
    total_boosters
FROM covid_vaccinations
WHERE location LIKE "%states%"
ORDER BY location, date;


-- Total Cases VS Total Deaths
-- 		aka: 
-- 			likelihood of death once infected
SELECT 
	location, 
	DATE_FORMAT( STR_TO_DATE( date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, 
    total_cases, 
    total_deaths, 
    ( total_deaths/total_cases ) * 100 AS death_per_case, 
    population
FROM covid_deaths
WHERE location LIKE "%states%" -- <-- using US as example
ORDER BY location, date;


-- Total Cases VS Population 
-- 		aka: 
-- 			percentage of population that may get infected
SELECT 
	location, 
	DATE_FORMAT( STR_TO_DATE( date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, 
    new_cases, 
    total_cases, 
    ( total_cases/population ) * 100 AS cases_per_pop, 
    population
FROM covid_deaths
WHERE location LIKE "%states%" -- <-- using US as example
ORDER BY date;

 
-- Coutries with Highest INFECTION RATE compared to Population
-- 		NOTE: 
-- 			to see DEATH RATE, replace `total_cases` with `total_deaths`
SELECT 
	population, 
	location, 
    MAX(total_cases) AS max_infection_count, 
    MAX((total_cases/population))*100 AS infection_rate
FROM covid_deaths
WHERE continent NOT LIKE "0"
GROUP BY location, population
ORDER BY infection_rate DESC;


-- 	DEATH & INFECTION COUNT by continents
-- 		NOTE:
-- 			can also replace `continents` with `locations`
SELECT 
	continent, 
	SUM(new_cases) AS total_infected, 
    SUM(new_deaths) AS total_deaths, 
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM covid_deaths
WHERE continent NOT LIKE "0"
GROUP BY continent;


-- Overall Global Numbers
SELECT 
	SUM(new_cases) AS total_infected, 
    SUM(new_deaths) AS total_deaths, 
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM covid_deaths
WHERE continent NOT LIKE "0";


-- Daily Global Numbers
SELECT 
	DATE_FORMAT( STR_TO_DATE( date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, 
    SUM(new_cases) AS daily_global_infection, 
    SUM(new_deaths) AS daily_global_death, 
    (SUM(new_deaths) / SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent NOT LIKE "0"
	-- AND location LIKE "%states%"  <---- for daily location numbers 
GROUP BY date
ORDER BY date;


-- JOINING `covid_deaths` and `covid_vaccinations`
SELECT 
	death.location, 
    DATE_FORMAT( STR_TO_DATE( death.date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, 
    death.population,
    death.new_cases, 
	death.total_cases, 
    death.new_deaths, 
    death.total_deaths, 
    vax.new_tests, 
    vax.total_tests
FROM covid_deaths AS death
JOIN covid_vaccinations AS vax
	ON death.location = vax.location
    AND death.date = vax.date
WHERE death.continent NOT LIKE "0"
ORDER BY location, date;


-- Total Vaccinations VS Population
SELECT 
	death.continent, 
	death.location, 
    DATE_FORMAT( STR_TO_DATE( death.date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, 
    death.population,
    death.new_cases, 
	death.total_cases, 
    death.new_deaths, 
    death.total_deaths, 
    vax.new_tests, 
    vax.total_tests, 
    vax.new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY death.location 
				ORDER BY death.location, 
							DATE_FORMAT( STR_TO_DATE( death.date, '%c/%e/%y' ) , '%Y-%m-%d' )) AS cumsum_vaccinations -- <-- trynna figure out CUMSUM
FROM covid_deaths AS death
JOIN covid_vaccinations AS vax
	ON death.location = vax.location
    AND death.date = vax.date
WHERE death.continent NOT LIKE "0" 
	AND death.location LIKE "canada" -- using canada as example
ORDER BY death.location, date;


SELECT 
	death.continent, 
    death.location, 
    DATE_FORMAT( STR_TO_DATE( death.date, '%c/%e/%y' ) , '%Y-%m-%d' ) AS date, 
    death.population,
    MAX(vax.total_vaccinations) as RollingPeopleVaccinated
FROM covid_deaths AS death
JOIN covid_vaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent NOT LIKE "0" 
GROUP BY death.continent, death.location, death.date, death.population;

