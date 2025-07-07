
-- Create schema to house the source tables
CREATE SCHEMA IF NOT EXISTS LND_MANUAL_ENTRY;

-- Create the calendar table
CREATE OR REPLACE TABLE LND_MANUAL_ENTRY.SSP_RR_CALENDAR (
    PROCESS_NAME VARCHAR(100),
    CALENDAR_YEAR NUMBER,
    CALENDAR_MONTH NUMBER,
    ACTIVE_FLG VARCHAR(1)
);

-- Insert sample data into the calendar table
INSERT INTO LND_MANUAL_ENTRY.SSP_RR_CALENDAR (PROCESS_NAME, CALENDAR_YEAR, CALENDAR_MONTH, ACTIVE_FLG) VALUES ('WSPD_MONTHLY', 2024, 7, 'Y');

-- Create the source tank detail table
CREATE OR REPLACE TABLE LND_MANUAL_ENTRY.SSP_TANK_DETAIL_SRC (
    tank_detail_id NUMBER,
    tank_name VARCHAR(100),
    product VARCHAR(100),
    capacity NUMBER,
    reading_date DATE
);

-- Insert sample data into the source tank detail table
INSERT INTO LND_MANUAL_ENTRY.SSP_TANK_DETAIL_SRC (tank_detail_id, tank_name, product, capacity, reading_date) VALUES (1, 'TANK-A', 'GASOLINE', 10000, '2024-07-15');
INSERT INTO LND_MANUAL_ENTRY.SSP_TANK_DETAIL_SRC (tank_detail_id, tank_name, product, capacity, reading_date) VALUES (2, 'TANK-B', 'DIESEL', 12000, '2024-07-16');
