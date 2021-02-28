-- the whole schema is replicated 3 times
CREATE SCHEMA bbdata2
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };

-- raw data
CREATE TABLE bbdata2.raw_values (
    object_id int,
    timestamp timestamp,
    comment text,        -- optional
    month text,          -- format: YYYY-MM
    value text,
    PRIMARY KEY ((object_id, month), timestamp)
) WITH CLUSTERING ORDER BY (timestamp ASC);

-- aggregations
CREATE TABLE bbdata2.aggregations (
    minutes int,
    object_id int,
    date text,   -- form: YYYY-MM
    timestamp timestamp,

    last float,
    last_ts bigint,
    min float,
    max float,
    sum float,
    mean float,
    count int,
    -- std dev: keep intermediary data for late arrivals
    k float,  
    k_sum float,
    k_sum_2 float,
    std float,

    PRIMARY KEY ((minutes, object_id, date), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- statistics
CREATE TABLE bbdata2.objects_stats_counter (
    object_id int,
    n_reads counter,
    n_values counter,
    PRIMARY KEY (object_id)
);

CREATE TABLE bbdata2.objects_stats (
    object_id int,
    avg_sample_period float,
    last_ts timestamp,
    PRIMARY KEY (object_id)
);
