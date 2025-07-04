CREATE OR REPLACE FUNCTION get_upcoming_trips(user_id_param INT)
RETURNS TABLE (
    trip_id INT,
    name VARCHAR(255),
    description TEXT,
    start_date DATE,
    end_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.trip_id,
        t.name,
        t.description,
        t.start_date,
        t.end_date
    FROM
        Trip t
    WHERE
        t.user_id = user_id_param
        AND t.start_date >= CURRENT_DATE  -- ทริปที่ยังไม่เริ่ม หรือเริ่มวันนี้
        AND t.start_date <= (CURRENT_DATE + INTERVAL '7 days'); -- ทริปที่เริ่มภายใน 7 วันข้างหน้า
END;
$$ LANGUAGE plpgsql;
