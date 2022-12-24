-- Combining all 3 year data to perform analysis

CREATE TEMP TABLE all_year_data AS (SELECT * FROM data_2018
							UNION
						   SELECT * FROM data_2019
							UNION
							SELECT * FROM data_2020);

-- Calculating revenue by year
-- Excluding bookings that were canceled
-- Subtracting the discount percentage

CREATE TEMP TABLE all_year_data_wdisc AS (SELECT all_year_data.*, market_segment.discount
FROM all_year_data
LEFT JOIN market_segment ON all_year_data.market_segment = market_segment.market_segment);

SELECT arrival_date_year, ROUND(SUM(((stays_in_weekend_nights + stays_in_week_nights) * adr)* (1 - discount)), 2) AS revenue
FROM all_year_data_wdisc
WHERE is_canceled = 0
GROUP BY arrival_date_year
ORDER BY revenue;

-- Calculating revenue by hotel type and year

SELECT hotel, arrival_date_year, ROUND(SUM(((stays_in_weekend_nights + stays_in_week_nights) * adr)* (1 - discount)), 2) AS revenue
FROM all_year_data_wdisc
WHERE is_canceled = 0
GROUP BY arrival_date_year, hotel
ORDER BY revenue;

-- Calculating percentage of bookings by hotel type

CREATE TEMP TABLE cte_2 AS (SELECT hotel, COUNT(hotel) AS total_bookings
FROM all_year_data
WHERE is_canceled = 0
GROUP BY hotel);

SELECT hotel, ROUND(100 * total_bookings/(SELECT SUM(total_bookings) FROM cte_2), 2) AS percentage_of_bookings
FROM cte_2
GROUP BY hotel,total_bookings

-- Analyizing car parking spaces


CREATE TEMP TABLE cte_3 AS (SELECT hotel, COUNT(*) AS total_bookings, SUM(CASE
											  WHEN required_car_parking_spaces > 0
											 THEN 1
											 ELSE 0
											 END) AS car_park_users
FROM all_year_data
WHERE is_canceled =0
GROUP BY hotel);

-- Converting car_park_users into percentage

SELECT hotel, total_bookings, car_park_users,
100 * car_park_users/total_bookings AS perc_needing_parking
FROM cte_3
GROUP BY hotel, total_bookings, car_park_users
ORDER BY total_bookings DESC;

-- Parking trend by year

SELECT arrival_date_year, SUM(required_car_parking_spaces) AS parking_needs
FROM all_year_data
WHERE is_canceled = 0
GROUP BY arrival_date_year
ORDER BY arrival_date_year;







							
							
							
