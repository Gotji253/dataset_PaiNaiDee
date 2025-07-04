CREATE OR REPLACE FUNCTION recommend_places(user_id_param INT, recommendation_limit INT DEFAULT 5)
RETURNS TABLE (
    place_id INT,
    name VARCHAR(255),
    category VARCHAR(100),
    average_rating NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH user_favorite_categories AS (
        -- 1. ค้นหาหมวดหมู่ที่ผู้ใช้ชอบบ่อยที่สุด
        SELECT
            p.category,
            COUNT(p.category) AS category_count
        FROM
            Favorite f
        JOIN
            Place p ON f.place_id = p.place_id
        WHERE
            f.user_id = user_id_param
        GROUP BY
            p.category
        ORDER BY
            category_count DESC
        LIMIT 1 -- เอาเฉพาะหมวดหมู่ที่ชอบมากที่สุด (ถ้ามีหลายหมวดหมู่ที่จำนวนเท่ากัน จะสุ่มมา 1)
    ),
    places_in_preferred_category AS (
        -- 2. ดึงสถานที่ในหมวดหมู่ที่ผู้ใช้ชอบ (ถ้ามี)
        SELECT
            p.place_id,
            p.name,
            p.category
        FROM
            Place p
        WHERE
            EXISTS (SELECT 1 FROM user_favorite_categories ufc WHERE ufc.category = p.category)
    ),
    ranked_places AS (
        -- 3. คำนวณคะแนนเฉลี่ยและจัดอันดับสถานที่
        SELECT
            pic.place_id,
            pic.name,
            pic.category,
            calculate_average_rating(pic.place_id) AS avg_rating_calculated
        FROM
            places_in_preferred_category pic
        WHERE
            -- กรองสถานที่ที่ผู้ใช้ยังไม่เคยกด Favorite
            NOT EXISTS (
                SELECT 1
                FROM Favorite fav
                WHERE fav.user_id = user_id_param AND fav.place_id = pic.place_id
            )
    )
    -- 4. เลือกสถานที่แนะนำตามคะแนนเฉลี่ยสูงสุด
    SELECT
        rp.place_id,
        rp.name,
        rp.category,
        rp.avg_rating_calculated AS average_rating
    FROM
        ranked_places rp
    WHERE
        rp.avg_rating_calculated IS NOT NULL -- เอาเฉพาะที่มีการรีวิวแล้ว
    ORDER BY
        average_rating DESC, rp.name ASC -- จัดเรียงตามคะแนนเฉลี่ย, ถ้าเท่ากันเรียงตามชื่อ
    LIMIT recommendation_limit; -- จำกัดจำนวนผลลัพธ์

    -- กรณีที่ผู้ใช้ยังไม่มี Favorite หรือไม่มีสถานที่แนะนำจาก Favorite category
    -- อาจจะเพิ่ม Logic สำรอง เช่น แนะนำสถานที่ยอดนิยมโดยรวม หรือสถานที่ใหม่ๆ (ยังไม่ได้ใส่ในเวอร์ชันนี้)
END;
$$ LANGUAGE plpgsql;
