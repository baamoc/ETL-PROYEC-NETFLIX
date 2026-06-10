-- ============================================================
-- Script 02: Create staging tables (raw data from CSVs)
-- Schema: staging
-- All columns TEXT to avoid type errors on initial load.
-- ============================================================

-- Source: datasets/NetFlix.csv
-- Columns: show_id, type, title, director, cast, country,
--          date_added, release_year, rating, duration,
--          genres, description
DROP TABLE IF EXISTS staging.stg_netflix_titles;
CREATE TABLE staging.stg_netflix_titles (
    show_id      VARCHAR(10),
    type         VARCHAR(10),
    title        TEXT,
    director     TEXT,
    elenco       TEXT,
    country      TEXT,
    date_added   VARCHAR(20),
    release_year VARCHAR(4),
    rating       VARCHAR(10),
    duration     VARCHAR(10),
    genres       TEXT,
    description  TEXT
);

-- Source: datasets/Netflix Userbase.csv
-- Columns: User ID, Subscription Type, Monthly Revenue,
--          Join Date, Last Payment Date, Country, Age,
--          Gender, Device, Plan Duration
DROP TABLE IF EXISTS staging.stg_netflix_userbase;
CREATE TABLE staging.stg_netflix_userbase (
    user_id             VARCHAR(10),
    subscription_type   VARCHAR(20),
    monthly_revenue     VARCHAR(5),
    join_date           VARCHAR(10),
    last_payment_date   VARCHAR(10),
    country             VARCHAR(50),
    age                 VARCHAR(3),
    gender              VARCHAR(10),
    device              VARCHAR(20),
    plan_duration       VARCHAR(20)
);
