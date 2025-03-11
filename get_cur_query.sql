\c postgres;

SELECT 
    pid, 
    usename, 
    application_name, 
    client_addr, 
    state, 
    query, 
    query_start, 
    NOW() - query_start AS duration
FROM 
    pg_stat_activity
WHERE 
    state = 'active'
    AND pid != pg_backend_pid()
ORDER BY 
    query_start DESC;