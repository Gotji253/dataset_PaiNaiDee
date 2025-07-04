CREATE OR REPLACE FUNCTION get_upcoming_trips(p_user_id INT, p_future_days INT)
RETURNS TABLE (
    trip_id INT,
    user_id INT,
    name VARCHAR(255),
    description TEXT,
    start_date DATE,
    end_date DATE,
    is_public BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.trip_id,
        t.user_id,
        t.name,
        t.description,
        t.start_date,
        t.end_date,
        t.is_public,
        t.created_at,
        t.updated_at
    FROM
        "Trip" t
    WHERE
        t.user_id = p_user_id
        AND t.start_date >= CURRENT_DATE
        AND t.start_date <= (CURRENT_DATE + MAKE_INTERVAL(days => p_future_days))
    ORDER BY
        t.start_date ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_upcoming_trips(INT, INT) IS 'Fetches upcoming trips for a given user within a specified number of future days, ordered by start date.';
