-- ============================================================
-- World Bank Economic Indicators - Database Schema
-- Star Schema Design (Kimball Methodology)
-- ============================================================

-- DIMENSION TABLE: Countries
-- Contains country metadata with regional classification
CREATE TABLE dim_country (
    country_id    INTEGER PRIMARY KEY,
    country_code  TEXT NOT NULL,        -- ISO 3-letter code (e.g., 'BGR')
    country_name  TEXT NOT NULL,        -- Full name (e.g., 'Bulgaria')
    region        TEXT NOT NULL         -- Eastern Europe, Western Europe, etc.
);

-- DIMENSION TABLE: Indicators
-- Contains economic indicator metadata
CREATE TABLE dim_indicator (
    indicator_id    INTEGER PRIMARY KEY,
    indicator_code  TEXT NOT NULL,      -- World Bank code (e.g., 'NY.GDP.PCAP.CD')
    indicator_name  TEXT NOT NULL,      -- Friendly name (e.g., 'gdp_per_capita')
    description     TEXT                -- Full description
);

-- FACT TABLE: Indicators
-- Contains all measurements (GDP, inflation, unemployment) per country/year
CREATE TABLE fact_indicators (
    fact_id       INTEGER PRIMARY KEY,
    country_id    INTEGER NOT NULL,     -- FK to dim_country
    indicator_id  INTEGER NOT NULL,     -- FK to dim_indicator
    year          INTEGER NOT NULL,     -- Measurement year
    value         REAL,                 -- Actual measurement value
    FOREIGN KEY (country_id)   REFERENCES dim_country(country_id),
    FOREIGN KEY (indicator_id) REFERENCES dim_indicator(indicator_id)
);

-- ============================================================
-- INDEXES for query performance
-- ============================================================
CREATE INDEX idx_fact_country  ON fact_indicators(country_id);
CREATE INDEX idx_fact_indicator ON fact_indicators(indicator_id);
CREATE INDEX idx_fact_year     ON fact_indicators(year);