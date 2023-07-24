-- Exploratory Analysis --

-- Client expectations
	-- Expand franchises into one of the most popular states for Chick-Fil-A
	-- Considering offering full-service locations with full amenities
	-- Wants to offer a full menu (i.e. location serves breakfast, lunch, & dinner)
	-- What can the client expect to competitively charge per state for chicken sandwiches?

select *
from cfaprojectforsql c;

-- How many states/territories does Chick-fil-A serve?
	-- CFA serves 48 states/territories (Washington DC included)
	-- Vermont, Alaska, and Hawaii do not carry CFA

select count(distinct state)
from cfaprojectforsql c;

-- Which States have the most locations?
	-- Texas 406, Georgia 232, Florida 213, California 169, North Carolina 162

select state, count(location) as num_locations
from cfaprojectforsql c
where sandwich_price is not null
group by 1
order by 2 desc;

-- What are the average sandwich prices in the above (full-service) locations?
	-- California $5.74, Florida $5.04, Texas $4.88, North Carolina $4.80, Georgia $4.80

select state, avg(sandwich_price) as avg_price
from cfaprojectforsql c
where mobile_orders = 'Yes' 
	and catering = 'Yes'
	and pickup = 'Yes'
	and delivery = 'Yes'
	and wifi = 'Yes'
	and playground = 'Yes'
	and breakfast_served = 'Yes'
	and drive_thru = 'Yes'
	and sandwich_price is not null
	and state in ('tx', 'ga', 'fl', 'ca', 'nc')
group by 1
order by 2 desc;

-- How does the price change for CFAs that don't have expanded real estate?
	-- This refers to locations without a playground or drive-thru
	-- California $5.91, Florida $5.29, Texas $5.15, North Carolina $5.09, Georgia $5.02
	-- The average price increases when these states don't have expanded real estate

select state, avg(sandwich_price) as avg_price
from cfaprojectforsql c
where mobile_orders = 'Yes' 
	and catering = 'Yes'
	and pickup = 'Yes'
	and delivery = 'Yes'
	and wifi = 'Yes'
	and playground = 'No'
	and breakfast_served = 'Yes'
	and drive_thru = 'No'
	and sandwich_price is not null
	and state in ('tx', 'ga', 'fl', 'ca', 'nc')
group by 1
order by 2 desc;

-- How does the price change for CFAs when WiFi is not available?
	-- California $5.71, Florida $4.97, Texas $4.82, Georgia $4.75, North Carolina $4.75
	-- These prices are lower than the prices for sandwiches under the same conditions where WiFi is available
	-- The client can expect to build the price of WiFi into increased sandwich costs

select state, avg(sandwich_price) as avg_price
from cfaprojectforsql c
where mobile_orders = 'Yes' 
	and catering = 'Yes'
	and pickup = 'Yes'
	and delivery = 'Yes'
	and wifi = 'No'
	and playground = 'Yes'
	and breakfast_served = 'Yes'
	and drive_thru = 'Yes'
	and sandwich_price is not null
	and state in ('tx', 'ga', 'fl', 'ca', 'nc')
group by 1
order by 2 desc;

-- Price expectations when franchising on a university or college campus/street?
	-- California $5.69, Florida $5.10, Georgia $5.09, Texas $4.93, North Carolina $4.78

select state, avg(sandwich_price) as avg_price
from cfaprojectforsql c
where (location like '%University%' or location like '%College%')
	and state in ('tx', 'ga', 'fl', 'ca', 'nc')
	and sandwich_price is not null
group by 1
order by 2 desc;

-- Max/Min price expectation for a location per state with full-service/amenities?
	-- Max: California $5.89, Florida $5.25, Texas $5.09, Georgia $4.99, North Carolina $4.95
	-- Min: California $5.45, Florida $4.89, Texas $4.75, Georgia $4.75, North Carolina $4.75

select state, max(sandwich_price) as max_price, min(sandwich_price) as min_price
from cfaprojectforsql c
where mobile_orders = 'Yes' 
	and catering = 'Yes'
	and pickup = 'Yes'
	and delivery = 'Yes'
	and wifi = 'Yes'
	and playground = 'Yes'
	and breakfast_served = 'Yes'
	and drive_thru = 'Yes'
	and sandwich_price is not null
	and state in ('tx', 'ga', 'fl', 'ca', 'nc')
group by 1
order by 2 desc;
