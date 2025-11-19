-- Group hosts by hardware info
SELECT
    id,
    cpu_number,
    total_mem
FROM
    public.host_info G
ORDER BY
    cpu_number,
    total_mem DESC;

-- Average memory usage
SELECT
    host_id,
    hostname,
    round5(host_usage.timestamp) as timestamp,
    avg(
            (total_mem - memory_free) * 100.0 / total_mem
    ) as avg_used_mem_percentage
FROM
    host_usage
        JOIN host_info ON host_info.id = host_usage.host_id
GROUP BY
    host_id,
    hostname,
    round5(host_usage.timestamp);

CREATE FUNCTION round5(ts timestamp) RETURNS timestamp AS
$$
BEGIN
    RETURN date_trunc('hour', ts) + date_part('minute', ts):: int / 5 * interval '5 min';
END;
$$
    LANGUAGE PLPGSQL;

-- Detect host failure
SELECT
    host_id,
    round5(host_usage.timestamp) as ts,
    count(host_usage.host_id) as num_data_points
FROM
    host_usage
GROUP BY
    host_id,
    round5(host_usage.timestamp)
HAVING
    COUNT(*) < 3;


