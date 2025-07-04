CREATE OR REPLACE FUNCTION calculate_average_rating(place_id_param INT)
RETURNS NUMERIC AS $$
DECLARE
    avg_rating NUMERIC;
BEGIN
    SELECT AVG(rating)
    INTO avg_rating
    FROM Review
    WHERE place_id = place_id_param;

    RETURN avg_rating;
END;
$$ LANGUAGE plpgsql;
