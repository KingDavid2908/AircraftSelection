-- Data Cleaning and Exploratory Analysis Project 1 (Airplane Bluebook)
-- In this project I was tasked as a data analyst to choose an aircraft an aviation company(Oxygen Air) would use to start commercial
-- transportation. The aircraft chosen should consume less fuel, carry more load and have a wide range.
-- I decided to selecting the aircraft based on Fuel, Engine HP, Maximum number of passenger it can carry(Gross weight - Empty weight),
-- and Range

select *
from airplane_bluebook;

ALTER TABLE airplane_bluebook 
RENAME COLUMN `HP or lbs thr ea engine` TO `Engine Power HP`;


-- 1. Data Cleaning

create table aircraft_bluebook
like airplane_bluebook;

insert aircraft_bluebook
select *
from airplane_bluebook;

select *
from aircraft_bluebook;

-- a. Remove duplicates
With duplicate_ctes as 
(
select *,
row_number() over(partition by Model, `Company`, `Engine Type`, `Engine Power HP`,
`Max speed Knots`, `Rcmnd cruise Knots`, `Stall Knots dirty`, `Fuel gal/lbs`,
`All eng service ceiling`, `Eng out service ceiling`, `All eng rate of climb`,
`Eng out rate of climb`, `Takeoff over 50ft`, `Takeoff ground run`,
`Landing over 50ft`, `Landing ground roll`, `Gross weight lbs`, `Empty weight lbs`,
`Length ft/in`, `Height ft/in`, `Wing span ft/in`, `Range N.M.`) as row_num
from airplane_bluebook
)

select *
from duplicate_ctes
where row_num > 1
;

-- Note: No duplicates was identified in the dataset

-- b. Standardize the data
select *,
row_number() over()	as `Row Num` 
from aircraft_bluebook; -- last row number is 559

select distinct `Model`
from aircraft_bluebook
order by `Model`;  -- No close repetitions observed

select distinct `Company`
from aircraft_bluebook
order by `Company`;  -- No close repetitions observed

select distinct `Engine Type`
from aircraft_bluebook
order by `Engine Type`;  -- One close repetitions observed (Piston and Pistion)

select *
from aircraft_bluebook
where `Engine Type` = 'pistion';  -- Found just one aircraft with model 'PA-32R-301T Saratoga II TC' which makes it likely a typo

select *
from aircraft_bluebook
where `Engine Type` like 'pist%';

update aircraft_bluebook
set `Engine Type` = 'Piston'
where `Engine Type` like 'pist%';  -- Standardized the Engine Type column

select distinct `Engine Power HP`
from aircraft_bluebook
order by `Engine Power HP`;  -- No close repetitions observed

select distinct `Fuel gal/lbs`
from aircraft_bluebook
order by `Fuel gal/lbs`;  -- No close repetitions observed

select distinct `Gross weight lbs`
from aircraft_bluebook
order by `Gross weight lbs`;  -- No close repetitions observed

select distinct `Empty weight lbs`
from aircraft_bluebook
order by `Empty weight lbs`;  -- No close repetitions observed

select distinct `Range N.M.`
from aircraft_bluebook
order by `Range N.M.`;  -- No close repetitions observed

-- Useful columns have been standardized

-- c. Remove null or blank values
-- No null or blank values in useful tables

-- d. Remove unnecessary columns or rows

select *
from aircraft_bluebook;

-- I would be using the following columns:
-- Model, Company, Engine Type, Engine Power HP, Gross weight lbs, Empty weight lbs and Range N.M.
-- I would be deleting all the other columns

alter table aircraft_bluebook
drop `Max speed Knots`
;

alter table aircraft_bluebook
drop `Rcmnd cruise Knots`
;

alter table aircraft_bluebook
drop `Stall Knots dirty`
;

alter table aircraft_bluebook
drop `All eng service ceiling`
;

alter table aircraft_bluebook
drop `Eng out service ceiling`
;

alter table aircraft_bluebook
drop `All eng rate of climb`
;

alter table aircraft_bluebook
drop `Eng out rate of climb`
;

alter table aircraft_bluebook
drop `Takeoff over 50ft`
;

alter table aircraft_bluebook
drop `Takeoff ground run`
;

alter table aircraft_bluebook
drop `Landing over 50ft`
;

alter table aircraft_bluebook
drop `Landing ground roll`
;

alter table aircraft_bluebook
drop `Length ft/in`
;

alter table aircraft_bluebook
drop `Height ft/in`
;

alter table aircraft_bluebook
drop `Wing span ft/in`
;

select (`Gross weight lbs` - `Empty weight lbs`) as `Maximum Passenger weight lbs`
from aircraft_bluebook;

alter table aircraft_bluebook
add `Maximum Passenger weight lbs` int
;

update aircraft_bluebook
set `Maximum Passenger weight lbs` = `Gross weight lbs` - `Empty weight lbs`;

alter table aircraft_bluebook
drop `Gross weight lbs`
;

alter table aircraft_bluebook
drop `Empty weight lbs`
;

-- 2. Data Exploration Analysis

select *
from (
select *,
rank() over(
order by `Maximum Passenger weight lbs` desc, 
`Fuel gal/lbs` asc, 
`Engine Power HP` desc, 
`Range N.M.` desc
) as `Choice Rank`
from aircraft_bluebook
where `Fuel gal/lbs` < 1000
order by `Maximum Passenger weight lbs` desc, 
`Fuel gal/lbs` desc, 
`Engine Power HP` desc, 
`Range N.M.` desc) as best_choices
where `Choice Rank` <= 5   -- To choose the best 5 aircrafts 
;

-- It can be observed rom the dataset that the 'JET' Engine Type satisfied my criteria and the Bombardier Aerospace Business Aircraft
-- company produced aircrafts that fits my choice because fuel usage should not be up to 1000 gal/lbs to reduce cost per travel. 

-- Another way of choosing can be done below
select avg(`Maximum Passenger weight lbs`), avg(`Fuel gal/lbs`), avg(`Engine Power HP`), avg(`Range N.M.`)
from aircraft_bluebook
;

select *
from aircraft_bluebook
where (`Maximum Passenger weight lbs` > 2500) and
(`Fuel gal/lbs` < 1000) and 
(`Engine Power HP` > 1000) and 
(`Range N.M.`) > 1000;

-- We can see that this method of selection supports the first method used but narrows down the choices to a few aircrafts .

-- Would create a table to explore this table more

create table best_aircrafts
like aircraft_bluebook;

insert best_aircrafts
select *
from aircraft_bluebook
where (`Maximum Passenger weight lbs` > 2500) and
(`Fuel gal/lbs` < 1000) and 
(`Engine Power HP` > 1000) and 
(`Range N.M.`) > 1000;

select *
from best_aircrafts;

alter table best_aircrafts
add `Fuel gal` int;

update best_aircrafts
set `Fuel gal` = `Fuel gal/lbs` * `Maximum Passenger weight lbs`;

select  min(`Fuel gal`)
from best_aircrafts;

select *
from best_aircrafts
where `Fuel gal` = 1683576;

-- The best aircraft to choose is 'Pilatus Business Aircraft' model 'PC-12' because it has a low fuel usage(good) , high range(good),
-- engine type of 'Propjet' which is different, low engine power(bad but not priority) and has a moderate maximum passenger weight(okay).