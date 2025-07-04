CREATE OR REPLACE FUNCTION get_popular_places(p_limit INT)
RETURNS TABLE (
    place_id INT,
    name VARCHAR(255),
    description TEXT,
    address VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    website VARCHAR(255),
    average_rating DECIMAL(3, 2),
    created_by_user_id INT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    review_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.place_id,
        p.name,
        p.description,
        p.address,
        p.latitude,
        p.longitude,
        p.contact_email,
        p.contact_phone,
        p.website,
        p.average_rating,
        p.created_by_user_id,
        p.created_at,
        p.updated_at,
        COUNT(r.review_id) AS review_count
    FROM
        "Place" p
    LEFT JOIN
        "Review" r ON p.place_id = r.place_id
    GROUP BY
        p.place_id -- Group by place_id and all other columns of Place due to SQL standards
    ORDER BY
        p.average_rating DESC,
        review_count DESC,
        p.name ASC
    LIMIT
        p_limit;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_popular_places(INT) IS 'Fetches globally popular places, ordered by average rating (desc) and review count (desc), limited by p_limit.';
